import SwiftData
import Foundation

@Model
final class ImageAttachment {
    var id: UUID
    var filename: String
    @Attribute(.externalStorage)
    var imageData: Data
    var altText: String?
    var markdownReference: String
    var note: Note?

    init(
        id: UUID = UUID(),
        filename: String,
        imageData: Data,
        altText: String? = nil,
        markdownReference: String = "",
        note: Note? = nil
    ) {
        self.id = id
        self.filename = filename
        self.imageData = imageData
        self.altText = altText
        self.markdownReference = markdownReference.isEmpty
            ? "![\\(altText ?? filename)](attachment:\\(id.uuidString))"
            : markdownReference
        self.note = note
    }
}
