import SwiftData
import Foundation

@Model
final class PublishRecord {
    var id: UUID
    var platform: String
    var publishedAt: Date
    var externalID: String
    var externalURL: String?
    var note: Note?

    init(
        id: UUID = UUID(),
        platform: String,
        publishedAt: Date = .now,
        externalID: String,
        externalURL: String? = nil,
        note: Note? = nil
    ) {
        self.id = id
        self.platform = platform
        self.publishedAt = publishedAt
        self.externalID = externalID
        self.externalURL = externalURL
        self.note = note
    }
}
