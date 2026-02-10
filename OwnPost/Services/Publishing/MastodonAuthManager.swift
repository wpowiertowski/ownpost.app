import Foundation
import AuthenticationServices

actor MastodonAuthManager {
    private var instanceURL: URL?
    private var clientID: String?
    private var clientSecret: String?
    private var accessToken: String?

    private let redirectURI = "ownpost://oauth"
    private let scopes = "write:statuses write:media"

    enum MastodonAuthError: Error, LocalizedError {
        case notConfigured
        case registrationFailed
        case authorizationFailed
        case tokenExchangeFailed
        case noAccessToken

        var errorDescription: String? {
            switch self {
            case .notConfigured: "Mastodon instance is not configured"
            case .registrationFailed: "Failed to register app with Mastodon instance"
            case .authorizationFailed: "Authorization was cancelled or failed"
            case .tokenExchangeFailed: "Failed to exchange authorization code for token"
            case .noAccessToken: "No Mastodon access token available"
            }
        }
    }

    /// Step 1: Register app with Mastodon instance
    func registerApp(instanceURL: URL) async throws {
        self.instanceURL = instanceURL

        struct RegisterRequest: Encodable {
            let client_name: String
            let redirect_uris: String
            let scopes: String
        }

        struct RegisterResponse: Decodable {
            let client_id: String
            let client_secret: String
        }

        let url = instanceURL.appendingPathComponent("api/v1/apps")
        let response: RegisterResponse = try await HTTPClient.shared.request(
            url,
            method: "POST",
            body: RegisterRequest(
                client_name: "OwnPost",
                redirect_uris: redirectURI,
                scopes: scopes
            ),
            responseType: RegisterResponse.self
        )

        self.clientID = response.client_id
        self.clientSecret = response.client_secret
    }

    /// Get the OAuth authorization URL to open in ASWebAuthenticationSession
    func authorizationURL() throws -> URL {
        guard let instanceURL, let clientID else {
            throw MastodonAuthError.notConfigured
        }

        var components = URLComponents(url: instanceURL.appendingPathComponent("oauth/authorize"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code")
        ]

        guard let url = components.url else {
            throw MastodonAuthError.notConfigured
        }
        return url
    }

    /// Step 2: Exchange authorization code for access token
    func exchangeCode(_ code: String) async throws {
        guard let instanceURL, let clientID, let clientSecret else {
            throw MastodonAuthError.notConfigured
        }

        struct TokenRequest: Encodable {
            let grant_type: String
            let code: String
            let client_id: String
            let client_secret: String
            let redirect_uri: String
        }

        struct TokenResponse: Decodable {
            let access_token: String
        }

        let url = instanceURL.appendingPathComponent("oauth/token")
        let response: TokenResponse = try await HTTPClient.shared.request(
            url,
            method: "POST",
            body: TokenRequest(
                grant_type: "authorization_code",
                code: code,
                client_id: clientID,
                client_secret: clientSecret,
                redirect_uri: redirectURI
            ),
            responseType: TokenResponse.self
        )

        self.accessToken = response.access_token

        // Persist to Keychain
        let credentials = MastodonCredentials(
            instanceURL: instanceURL,
            clientID: clientID,
            clientSecret: clientSecret,
            accessToken: response.access_token
        )
        try await KeychainManager.shared.save(key: MastodonCredentials.keychainKey, value: credentials)
    }

    /// Load saved credentials from Keychain
    func loadFromKeychain() async throws {
        guard let credentials = try await KeychainManager.shared.read(
            key: MastodonCredentials.keychainKey,
            as: MastodonCredentials.self
        ) else { return }

        self.instanceURL = credentials.instanceURL
        self.clientID = credentials.clientID
        self.clientSecret = credentials.clientSecret
        self.accessToken = credentials.accessToken
    }

    func getAccessToken() throws -> String {
        guard let token = accessToken else { throw MastodonAuthError.noAccessToken }
        return token
    }

    func getInstanceURL() throws -> URL {
        guard let url = instanceURL else { throw MastodonAuthError.notConfigured }
        return url
    }

    var isConfigured: Bool {
        accessToken != nil && instanceURL != nil
    }
}
