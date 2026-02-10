import SwiftUI
import FoundationModels

struct AISettingsView: View {
    @State private var isAvailable = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("On-Device AI")
                    Spacer()
                    if isAvailable {
                        Label("Available", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("Unavailable", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("AI Status")
            } footer: {
                if isAvailable {
                    Text("On-device AI is available for proofreading and alt text generation. All processing happens locally on your device.")
                } else {
                    Text("On-device AI requires iOS 18.1+ or macOS 15.1+ on supported hardware. AI features will be disabled.")
                }
            }

            Section("Features") {
                Label("Proofreading", systemImage: "text.magnifyingglass")
                    .foregroundStyle(isAvailable ? .primary : .secondary)
                Label("Alt Text Generation", systemImage: "photo.badge.checkmark")
                    .foregroundStyle(isAvailable ? .primary : .secondary)
            }
        }
        .navigationTitle("AI")
        .onAppear {
            isAvailable = SystemLanguageModel.default.isAvailable
        }
    }
}
