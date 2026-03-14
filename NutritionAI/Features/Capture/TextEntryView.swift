import SwiftUI

struct TextEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mealDescription = ""
    let onSubmit: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Describe what you ate")
                    .font(.headline)
                    .padding(.top)

                TextEditor(text: $mealDescription)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                Text("Example: \"Grilled chicken breast with rice and steamed broccoli\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                Spacer()

                Button {
                    onSubmit(mealDescription)
                } label: {
                    Text("Analyze")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(mealDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
            .navigationTitle("Text Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
