import SwiftData
import Foundation

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var modifiedAt: Date
    var publishedAt: Date?
    var isPinned: Bool
    var tags: [String]

    // Publishing state
    var ghostPostID: String?
    var ghostURL: String?
    var mastodonStatusID: String?
    var blueskyURI: String?

    @Relationship(deleteRule: .cascade)
    var publishRecords: [PublishRecord]

    @Relationship(deleteRule: .cascade)
    var imageAttachments: [ImageAttachment]

    var isDraft: Bool {
        ghostPostID == nil
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        body: String = "",
        createdAt: Date = .now,
        modifiedAt: Date = .now,
        publishedAt: Date? = nil,
        isPinned: Bool = false,
        tags: [String] = [],
        ghostPostID: String? = nil,
        ghostURL: String? = nil,
        mastodonStatusID: String? = nil,
        blueskyURI: String? = nil,
        publishRecords: [PublishRecord] = [],
        imageAttachments: [ImageAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.publishedAt = publishedAt
        self.isPinned = isPinned
        self.tags = tags
        self.ghostPostID = ghostPostID
        self.ghostURL = ghostURL
        self.mastodonStatusID = mastodonStatusID
        self.blueskyURI = blueskyURI
        self.publishRecords = publishRecords
        self.imageAttachments = imageAttachments
    }
}
