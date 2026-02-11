import Foundation

struct GhostCredentials: Codable, Sendable {
    var apiURL: URL
    var adminAPIKey: String

    var keyID: String? {
        let parts = adminAPIKey.split(separator: ":")
        guard parts.count == 2 else { return nil }
        return String(parts[0])
    }

    var keySecret: String? {
        let parts = adminAPIKey.split(separator: ":")
        guard parts.count == 2 else { return nil }
        return String(parts[1])
    }

    static let keychainKey = "ghost.credentials"

    enum CodingKeys: String, CodingKey {
        case apiURL
        case adminAPIKey
    }

    nonisolated init(apiURL: URL, adminAPIKey: String) {
        self.apiURL = apiURL
        self.adminAPIKey = adminAPIKey
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        apiURL = try container.decode(URL.self, forKey: .apiURL)
        adminAPIKey = try container.decode(String.self, forKey: .adminAPIKey)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(apiURL, forKey: .apiURL)
        try container.encode(adminAPIKey, forKey: .adminAPIKey)
    }
}
