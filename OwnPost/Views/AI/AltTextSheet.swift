import SwiftUI

struct AltTextSheet: View {
    @Bindable var attachment: ImageAttachment
    @Environment(\.dismiss) private var dismiss
    @State private var generatedText = ""
    @State private var isGenerating = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    #if os(iOS)
                    if let uiImage = UIImage(data: attachment.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: attachment.imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    #endif
                }

                Section("Alt Text") {
                    TextField("Describe this image...", text: Binding(
                        get: { attachment.altText ?? "" },
                        set: { attachment.altText = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }

                if isGenerating {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Generating with on-device AI...")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .navigationTitle("Alt Text")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate") {
                        Task { await generateAltText() }
                    }
                    .disabled(isGenerating)
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 400)
        #endif
    }

    private func generateAltText() async {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let service = AltTextService()
            try await service.initialize()
            let text = try await service.generateAltText(for: attachment.imageData)
            attachment.altText = text
        } catch {
            self.error = error.localizedDescription
        }
    }
}
