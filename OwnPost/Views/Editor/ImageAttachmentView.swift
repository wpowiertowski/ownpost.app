import SwiftUI
import PhotosUI

struct ImageAttachmentView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedAttachment: ImageAttachment?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !note.imageAttachments.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(note.imageAttachments) { attachment in
                            imageCard(for: attachment)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                Label("Add Image", systemImage: "photo.badge.plus")
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadImage(from: newItem)
            }
        }
        .sheet(item: $selectedAttachment) { attachment in
            AltTextSheet(attachment: attachment)
        }
    }

    @ViewBuilder
    private func imageCard(for attachment: ImageAttachment) -> some View {
        VStack {
            if let image = platformImage(from: attachment.imageData) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Text(attachment.altText ?? "No alt text")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .onTapGesture {
            selectedAttachment = attachment
        }
        .contextMenu {
            Button("Edit Alt Text") {
                selectedAttachment = attachment
            }
            Button("Remove", role: .destructive) {
                modelContext.delete(attachment)
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }

        let attachment = ImageAttachment(
            filename: "image-\(UUID().uuidString.prefix(8)).jpg",
            imageData: data,
            note: note
        )
        modelContext.insert(attachment)
        note.imageAttachments.append(attachment)
        note.body += "\n\n\(attachment.markdownReference)"
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
