import AVFoundation
import SwiftUI
import UIKit

enum CameraFlashMode {
    case auto, on, off
}

enum CameraServiceError: Error {
    case notAuthorized
    case configurationFailed
    case captureFailed
}

final class CameraService: NSObject, @unchecked Sendable {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let output = AVCapturePhotoOutput()
    private var device: AVCaptureDevice?
    private var currentFlashMode: CameraFlashMode = .auto
    private var activePhotoDelegates: [PhotoDelegate] = []
    private var orientationObserver: NSObjectProtocol?
    private var lastKnownDeviceOrientation: UIDeviceOrientation = .portrait

    var authorizationStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }

    var isFlashAvailable: Bool {
        device?.isFlashAvailable ?? false
    }

    override init() {
        super.init()
        configureOrientationMonitoring()
    }

    deinit {
        if let observer = orientationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func requestAuthorization() async -> AVAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .notDetermined else { return status }
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    }

    func startSession() {
        sessionQueue.async {
            guard self.authorizationStatus == .authorized else { return }
            if self.session.inputs.isEmpty {
                do { try self.configureSession() } catch { return }
            }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func setFlashMode(_ mode: CameraFlashMode) {
        currentFlashMode = mode
    }

    func capturePhoto() async throws -> UIImage {
        guard authorizationStatus == .authorized else {
            throw CameraServiceError.notAuthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            let settings = AVCapturePhotoSettings()
            switch currentFlashMode {
            case .auto: settings.flashMode = .auto
            case .on: settings.flashMode = .on
            case .off: settings.flashMode = .off
            }
            if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
                connection.videoOrientation = resolvedVideoOrientation()
            }

            var captureRef: PhotoDelegate?
            let delegate = PhotoDelegate { [weak self] result in
                if let ref = captureRef, let self,
                   let idx = self.activePhotoDelegates.firstIndex(where: { $0 === ref }) {
                    self.activePhotoDelegates.remove(at: idx)
                }
                continuation.resume(with: result)
            }
            captureRef = delegate
            activePhotoDelegates.append(delegate)
            output.capturePhoto(with: settings, delegate: delegate)
        }
    }

    private func configureSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            throw CameraServiceError.configurationFailed
        }
        self.device = camera

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) { session.addInput(input) }
        } catch {
            session.commitConfiguration()
            throw CameraServiceError.configurationFailed
        }

        if session.canAddOutput(output) { session.addOutput(output) }
        output.isHighResolutionCaptureEnabled = true
        session.commitConfiguration()
    }

    private func configureOrientationMonitoring() {
        let device = UIDevice.current
        device.beginGeneratingDeviceOrientationNotifications()
        lastKnownDeviceOrientation = device.orientation
        orientationObserver = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            let orientation = UIDevice.current.orientation
            if [.landscapeLeft, .landscapeRight, .portrait].contains(orientation) {
                self?.lastKnownDeviceOrientation = orientation
            }
        }
    }

    private func resolvedVideoOrientation() -> AVCaptureVideoOrientation {
        switch lastKnownDeviceOrientation {
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        default: .portrait
        }
    }
}

// MARK: - Photo Delegate

private final class PhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<UIImage, Error>) -> Void
    init(completion: @escaping (Result<UIImage, Error>) -> Void) { self.completion = completion }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            completion(.failure(error))
            return
        }
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            completion(.success(image))
        } else {
            completion(.failure(CameraServiceError.captureFailed))
        }
    }
}

// MARK: - SwiftUI Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

final class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
