import SwiftUI

struct AltTextSheet: View {
    @Bindable var attachment: ImageAttachment
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Image") {
                    if let image = platformImage(from: attachment.imageData) {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
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
                    Button("Save") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Generate") {
                        Task { await generateAltText() }
                    }
                    .disabled(isGenerating)
                }
            }
        }
    }

    private func generateAltText() async {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let service = try AltTextService()
            let text = try await service.generateAltText(
                for: attachment.filename
            )
            attachment.altText = text
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if os(iOS)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
}
