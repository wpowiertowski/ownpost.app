import Foundation

struct MastodonCredentials: Codable, Sendable {
    var instanceURL: URL
    var clientID: String
    var clientSecret: String
    var accessToken: String

    static let keychainKey = "mastodon.credentials"

    enum CodingKeys: String, CodingKey {
        case instanceURL
        case clientID
        case clientSecret
        case accessToken
    }

    nonisolated init(
        instanceURL: URL,
        clientID: String,
        clientSecret: String,
        accessToken: String
    ) {
        self.instanceURL = instanceURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.accessToken = accessToken
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        instanceURL = try container.decode(URL.self, forKey: .instanceURL)
        clientID = try container.decode(String.self, forKey: .clientID)
        clientSecret = try container.decode(String.self, forKey: .clientSecret)
        accessToken = try container.decode(String.self, forKey: .accessToken)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceURL, forKey: .instanceURL)
        try container.encode(clientID, forKey: .clientID)
        try container.encode(clientSecret, forKey: .clientSecret)
        try container.encode(accessToken, forKey: .accessToken)
    }
}
