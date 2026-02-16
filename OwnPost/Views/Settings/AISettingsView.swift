import SwiftUI
import FoundationModels

struct AISettingsView: View {
    @State private var isAvailable = false

    var body: some View {
        Form {
            Section {
                LabeledContent("Status") {
                    if isAvailable {
                        Label("Available", systemImage: "checkmark.circle.fill")
                            .font(Constants.Design.monoBody)
                            .foregroundStyle(Constants.Design.accentColor)
                    } else {
                        Label("Unavailable", systemImage: "xmark.circle")
                            .font(Constants.Design.monoBody)
                            .foregroundStyle(.secondary)
                    }
                }
                .font(Constants.Design.monoBody)
            } footer: {
                Text(isAvailable
                    ? "All processing happens locally on your device."
                    : "Requires Apple Intelligence on supported hardware.")
                    .font(Constants.Design.monoCaption)
            }

            Section {
                Label("Proofreading", systemImage: "text.magnifyingglass")
                    .font(Constants.Design.monoBody)
                    .foregroundStyle(isAvailable ? .primary : .secondary)

                Label("Alt Text Generation", systemImage: "photo")
                    .font(Constants.Design.monoBody)
                    .foregroundStyle(isAvailable ? .primary : .secondary)
            } header: {
                Text("Capabilities")
                    .font(Constants.Design.monoCaption)
            }
        }
        .navigationTitle("AI")
        .onAppear {
            isAvailable = SystemLanguageModel.default.isAvailable
        }
    }
}
