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
                    Text("On-device AI is available for proofreading and alt text generation. All processing happens locally — your data never leaves the device.")
                } else {
                    Text("On-device AI requires Apple Intelligence to be enabled on supported hardware. AI features will be disabled.")
                }
            }

            Section("Features") {
                Label {
                    VStack(alignment: .leading) {
                        Text("Proofreading")
                        Text("Grammar, spelling, and style suggestions via @Generable guided generation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "text.magnifyingglass")
                }
                .foregroundStyle(isAvailable ? .primary : .secondary)

                Label {
                    VStack(alignment: .leading) {
                        Text("Alt Text Generation")
                        Text("Concise image descriptions for accessibility")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "photo.badge.checkmark")
                }
                .foregroundStyle(isAvailable ? .primary : .secondary)
            }
        }
        .navigationTitle("AI")
        .onAppear {
            isAvailable = SystemLanguageModel.default.isAvailable
        }
    }
}
