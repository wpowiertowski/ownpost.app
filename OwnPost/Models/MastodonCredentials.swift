import Foundation

struct MastodonCredentials: Codable, Sendable {
    var instanceURL: URL
    var clientID: String
    var clientSecret: String
    var accessToken: String

    static let keychainKey = "mastodon.credentials"
}
