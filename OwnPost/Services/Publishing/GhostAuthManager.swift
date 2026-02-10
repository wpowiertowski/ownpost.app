import Foundation
import CryptoKit

actor GhostAuthManager {
    private var apiURL: URL?
    private var adminAPIKeyID: String?
    private var adminAPISecret: Data?

    enum GhostAuthError: Error, LocalizedError {
        case invalidKey
        case notConfigured
        case tokenGenerationFailed

        var errorDescription: String? {
            switch self {
            case .invalidKey: "Invalid Ghost Admin API key format. Expected {id}:{secret}"
            case .notConfigured: "Ghost API is not configured"
            case .tokenGenerationFailed: "Failed to generate Ghost JWT token"
            }
        }
    }

    /// Configure from a Ghost Admin API key format: `{id}:{secret}`
    func configure(apiURL: URL, adminAPIKey: String) async throws {
        let parts = adminAPIKey.split(separator: ":")
        guard parts.count == 2 else { throw GhostAuthError.invalidKey }

        self.apiURL = apiURL
        self.adminAPIKeyID = String(parts[0])

        // Decode hex secret
        let hexString = String(parts[1])
        guard let secretData = Data(hexString: hexString) else {
            throw GhostAuthError.invalidKey
        }
        self.adminAPISecret = secretData

        // Persist to Keychain
        let credentials = GhostCredentials(apiURL: apiURL, adminAPIKey: adminAPIKey)
        try await KeychainManager.shared.save(key: GhostCredentials.keychainKey, value: credentials)
    }

    /// Load saved credentials from Keychain
    func loadFromKeychain() async throws {
        guard let credentials = try await KeychainManager.shared.read(
            key: GhostCredentials.keychainKey,
            as: GhostCredentials.self
        ) else { return }

        try await configure(apiURL: credentials.apiURL, adminAPIKey: credentials.adminAPIKey)
    }

    /// Generate a short-lived JWT for Ghost Admin API
    func generateToken() throws -> String {
        guard let keyID = adminAPIKeyID, let secret = adminAPISecret else {
            throw GhostAuthError.notConfigured
        }

        let now = Int(Date().timeIntervalSince1970)

        // Header
        let header = #"{"alg":"HS256","typ":"JWT","kid":"\#(keyID)"}"#
        let headerBase64 = Data(header.utf8).base64URLEncoded()

        // Payload (5 minute expiry)
        let payload = #"{"iat":\#(now),"exp":\#(now + 300),"aud":"/admin/"}"#
        let payloadBase64 = Data(payload.utf8).base64URLEncoded()

        // Signature
        let message = "\(headerBase64).\(payloadBase64)"
        let key = SymmetricKey(data: secret)
        let signature = HMAC<SHA256>.authenticationCode(
            for: Data(message.utf8),
            using: key
        )
        let signatureBase64 = Data(signature).base64URLEncoded()

        return "\(headerBase64).\(payloadBase64).\(signatureBase64)"
    }

    var isConfigured: Bool {
        apiURL != nil && adminAPIKeyID != nil && adminAPISecret != nil
    }

    func getAPIURL() throws -> URL {
        guard let url = apiURL else { throw GhostAuthError.notConfigured }
        return url
    }
}

// MARK: - Data Hex & Base64URL Extensions

private extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex
        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }

    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
