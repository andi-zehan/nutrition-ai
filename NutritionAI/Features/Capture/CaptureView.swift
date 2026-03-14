import SwiftUI

struct CaptureView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = CaptureViewModel()
    @State private var showCamera = false
    @State private var showPhotoPicker = false
    @State private var showTextEntry = false
    @State private var showHintSheet = false
    @State private var navigateToReview = false

    private let cameraService = CameraService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if let photo = viewModel.capturedPhoto {
                    capturedPhotoView(photo)
                } else {
                    placeholderView
                }

                if viewModel.isAnalyzing {
                    ProgressView("Analyzing meal...")
                        .padding()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                if viewModel.capturedPhoto == nil && !viewModel.isAnalyzing {
                    inputButtons
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle("Capture")
            .navigationDestination(isPresented: $navigateToReview) {
                if let draft = viewModel.draft {
                    IngredientReviewView(draft: draft) {
                        viewModel.reset()
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraSheetView(cameraService: cameraService) { image in
                    viewModel.capturedPhoto = image
                    showCamera = false
                    showHintSheet = true
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoLibraryPicker(isPresented: $showPhotoPicker) { image in
                    viewModel.capturedPhoto = image
                    showHintSheet = true
                }
            }
            .sheet(isPresented: $showTextEntry) {
                TextEntryView { text in
                    viewModel.textDescription = text
                    showTextEntry = false
                    Task {
                        await viewModel.analyzeText()
                        if viewModel.draft != nil { navigateToReview = true }
                    }
                }
            }
            .sheet(isPresented: $showHintSheet) {
                HintSheetView(hint: $viewModel.textHint) {
                    showHintSheet = false
                    Task {
                        await viewModel.analyzePhoto()
                        if viewModel.draft != nil { navigateToReview = true }
                    }
                }
            }
            .onChange(of: navigateToReview) {
                // Reset if user navigated back
                if !navigateToReview && viewModel.draft == nil {
                    viewModel.reset()
                }
            }
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Log a Meal")
                .font(.title2.bold())
        }
    }

    private func capturedPhotoView(_ photo: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            if viewModel.isAnalyzing {
                EmptyView()
            } else {
                Button("Retake") {
                    viewModel.capturedPhoto = nil
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var inputButtons: some View {
        VStack(spacing: 12) {
            Button {
                showCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                showPhotoPicker = true
            } label: {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                showTextEntry = true
            } label: {
                Label("Describe Meal", systemImage: "text.bubble.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Camera Sheet

private struct CameraSheetView: View {
    let cameraService: CameraService
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isAuthorized = false

    var body: some View {
        ZStack {
            if isAuthorized {
                CameraPreviewView(session: cameraService.session)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    HStack(spacing: 40) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(.white)

                        Button {
                            Task {
                                if let image = try? await cameraService.capturePhoto() {
                                    let resized = ImageResizer.resize(image: image, longest: 1600)
                                    onCapture(resized)
                                }
                            }
                        } label: {
                            Circle()
                                .fill(.white)
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle().stroke(.white.opacity(0.5), lineWidth: 4)
                                        .frame(width: 82, height: 82)
                                )
                        }

                        Color.clear.frame(width: 50)
                    }
                    .padding(.bottom, 32)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Camera access needed")
                        .font(.headline)
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task {
            let status = await cameraService.requestAuthorization()
            isAuthorized = status == .authorized
            if isAuthorized { cameraService.startSession() }
        }
        .onDisappear { cameraService.stopSession() }
    }
}

// MARK: - Hint Sheet

private struct HintSheetView: View {
    @Binding var hint: String
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Add a hint (optional)")
                    .font(.headline)
                    .padding(.top)

                Text("Help the AI identify your meal more accurately.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("e.g., homemade pasta with pesto", text: $hint)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Analyze")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
            .navigationTitle("Photo Hint")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}
