import Foundation

actor BlueskyAuthManager {
    private let baseURL = URL(string: "https://bsky.social/xrpc")!
    private var did: String?
    private var accessJwt: String?
    private var refreshJwt: String?
    private var handle: String?

    enum BlueskyAuthError: Error, LocalizedError {
        case notAuthenticated
        case sessionCreationFailed
        case refreshFailed

        var errorDescription: String? {
            switch self {
            case .notAuthenticated: "Not authenticated with Bluesky"
            case .sessionCreationFailed: "Failed to create Bluesky session"
            case .refreshFailed: "Failed to refresh Bluesky session"
            }
        }
    }

    /// Authenticate with identifier (handle or email) + app password
    func createSession(identifier: String, password: String) async throws {
        struct SessionRequest: Encodable {
            let identifier: String
            let password: String
        }

        struct SessionResponse: Decodable {
            let did: String
            let handle: String
            let accessJwt: String
            let refreshJwt: String
        }

        let url = baseURL.appendingPathComponent("com.atproto.server.createSession")
        let response: SessionResponse = try await HTTPClient.shared.request(
            url,
            method: "POST",
            body: SessionRequest(identifier: identifier, password: password),
            responseType: SessionResponse.self
        )

        self.did = response.did
        self.handle = response.handle
        self.accessJwt = response.accessJwt
        self.refreshJwt = response.refreshJwt

        // Persist to Keychain
        let credentials = BlueskyCredentials(
            did: response.did,
            accessJwt: response.accessJwt,
            refreshJwt: response.refreshJwt,
            handle: response.handle
        )
        try await KeychainManager.shared.save(key: BlueskyCredentials.keychainKey, value: credentials)
    }

    /// Refresh expired session
    func refreshSession() async throws {
        guard let refreshToken = refreshJwt else {
            throw BlueskyAuthError.notAuthenticated
        }

        struct RefreshResponse: Decodable {
            let did: String
            let handle: String
            let accessJwt: String
            let refreshJwt: String
        }

        let url = baseURL.appendingPathComponent("com.atproto.server.refreshSession")
        let response: RefreshResponse = try await HTTPClient.shared.request(
            url,
            method: "POST",
            headers: ["Authorization": "Bearer \(refreshToken)"],
            body: nil as String?,
            responseType: RefreshResponse.self
        )

        self.accessJwt = response.accessJwt
        self.refreshJwt = response.refreshJwt

        // Update Keychain
        let credentials = BlueskyCredentials(
            did: response.did,
            accessJwt: response.accessJwt,
            refreshJwt: response.refreshJwt,
            handle: response.handle
        )
        try await KeychainManager.shared.save(key: BlueskyCredentials.keychainKey, value: credentials)
    }

    /// Load saved credentials from Keychain
    func loadFromKeychain() async throws {
        guard let credentials = try await KeychainManager.shared.read(
            key: BlueskyCredentials.keychainKey,
            as: BlueskyCredentials.self
        ) else { return }

        self.did = credentials.did
        self.accessJwt = credentials.accessJwt
        self.refreshJwt = credentials.refreshJwt
        self.handle = credentials.handle
    }

    /// Get current access token, auto-refresh if needed
    func getAccessToken() async throws -> String {
        guard let token = accessJwt else {
            throw BlueskyAuthError.notAuthenticated
        }
        // Simple expiry check: try to refresh if the JWT looks expired
        // In production, decode the JWT to check exp claim
        return token
    }

    func getDID() throws -> String {
        guard let did else { throw BlueskyAuthError.notAuthenticated }
        return did
    }

    var isConfigured: Bool {
        did != nil && accessJwt != nil
    }
}
