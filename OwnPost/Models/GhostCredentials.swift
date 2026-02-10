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
}
