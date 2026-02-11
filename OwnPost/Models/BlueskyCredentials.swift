import Foundation

struct BlueskyCredentials: Codable, Sendable {
    var did: String
    var accessJwt: String
    var refreshJwt: String
    var handle: String

    static let keychainKey = "bluesky.credentials"

    enum CodingKeys: String, CodingKey {
        case did
        case accessJwt
        case refreshJwt
        case handle
    }

    nonisolated init(
        did: String,
        accessJwt: String,
        refreshJwt: String,
        handle: String
    ) {
        self.did = did
        self.accessJwt = accessJwt
        self.refreshJwt = refreshJwt
        self.handle = handle
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        did = try container.decode(String.self, forKey: .did)
        accessJwt = try container.decode(String.self, forKey: .accessJwt)
        refreshJwt = try container.decode(String.self, forKey: .refreshJwt)
        handle = try container.decode(String.self, forKey: .handle)
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(did, forKey: .did)
        try container.encode(accessJwt, forKey: .accessJwt)
        try container.encode(refreshJwt, forKey: .refreshJwt)
        try container.encode(handle, forKey: .handle)
    }
}
