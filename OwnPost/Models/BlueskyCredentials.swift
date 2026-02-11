import Foundation

struct BlueskyCredentials: Codable, Sendable {
    var did: String
    var accessJwt: String
    var refreshJwt: String
    var handle: String

    static let keychainKey = "bluesky.credentials"
}
