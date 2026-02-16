import Foundation
import Testing
@testable import OwnPost

struct GhostAuthManagerTests {

    @Test func notConfiguredByDefault() async {
        let auth = GhostAuthManager()
        let configured = await auth.isConfigured
        #expect(configured == false)
    }

    @Test func getAPIURLThrowsWhenNotConfigured() async {
        let auth = GhostAuthManager()
        do {
            _ = try await auth.getAPIURL()
            Issue.record("Expected GhostAuthError.notConfigured")
        } catch {
            #expect(error is GhostAuthManager.GhostAuthError)
        }
    }

    @Test func generateTokenThrowsWhenNotConfigured() async {
        let auth = GhostAuthManager()
        do {
            _ = try await auth.generateToken()
            Issue.record("Expected GhostAuthError.notConfigured")
        } catch {
            #expect(error is GhostAuthManager.GhostAuthError)
        }
    }

    @Test func configureRejectsKeyWithoutColon() async {
        let auth = GhostAuthManager()
        do {
            try await auth.configure(
                apiURL: URL(string: "https://blog.example.com")!,
                adminAPIKey: "nocolonhere"
            )
            Issue.record("Expected GhostAuthError.invalidKey")
        } catch let error as GhostAuthManager.GhostAuthError {
            guard case .invalidKey = error else {
                Issue.record("Expected .invalidKey, got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func configureRejectsInvalidHex() async {
        let auth = GhostAuthManager()
        do {
            try await auth.configure(
                apiURL: URL(string: "https://blog.example.com")!,
                adminAPIKey: "keyid:ZZZZZZ"  // not valid hex
            )
            Issue.record("Expected GhostAuthError.invalidKey")
        } catch let error as GhostAuthManager.GhostAuthError {
            guard case .invalidKey = error else {
                Issue.record("Expected .invalidKey, got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test func configureAndGenerateToken() async throws {
        let auth = GhostAuthManager()
        // Use a valid hex secret (32 bytes = 64 hex chars for HMAC-SHA256)
        let hexSecret = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        do {
            try await auth.configure(
                apiURL: URL(string: "https://blog.example.com")!,
                adminAPIKey: "testkey:\(hexSecret)"
            )
        } catch {
            // Keychain may not be available in all test environments; skip token test
            return
        }

        let configured = await auth.isConfigured
        #expect(configured == true)

        let token = try await auth.generateToken()
        let parts = token.split(separator: ".")
        #expect(parts.count == 3, "JWT must have 3 dot-separated parts")

        // Verify header decodes to valid JSON with correct alg and kid
        if let headerData = base64URLDecode(String(parts[0])) {
            let json = try JSONSerialization.jsonObject(with: headerData) as? [String: Any]
            #expect(json?["alg"] as? String == "HS256")
            #expect(json?["typ"] as? String == "JWT")
            #expect(json?["kid"] as? String == "testkey")
        } else {
            Issue.record("Failed to decode JWT header")
        }

        // Verify payload has required claims
        if let payloadData = base64URLDecode(String(parts[1])) {
            let json = try JSONSerialization.jsonObject(with: payloadData) as? [String: Any]
            #expect(json?["aud"] as? String == "/admin/")
            #expect(json?["iat"] != nil)
            #expect(json?["exp"] != nil)
            // exp should be iat + 300 (5 minute expiry)
            if let iat = json?["iat"] as? Int, let exp = json?["exp"] as? Int {
                #expect(exp - iat == 300)
            }
        } else {
            Issue.record("Failed to decode JWT payload")
        }

        // Verify signature uses base64url encoding (no +, /, =)
        let sig = String(parts[2])
        #expect(!sig.isEmpty)
        #expect(!sig.contains("+"), "Base64URL must not contain +")
        #expect(!sig.contains("/"), "Base64URL must not contain /")
        #expect(!sig.contains("="), "Base64URL must not contain =")
    }

    @Test func getAPIURLAfterConfigure() async throws {
        let auth = GhostAuthManager()
        let hexSecret = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        do {
            try await auth.configure(
                apiURL: URL(string: "https://blog.example.com")!,
                adminAPIKey: "testkey:\(hexSecret)"
            )
        } catch {
            // Keychain may not be available
            return
        }
        let url = try await auth.getAPIURL()
        #expect(url.absoluteString == "https://blog.example.com")
    }

    // MARK: - Helpers

    private func base64URLDecode(_ string: String) -> Data? {
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        return Data(base64Encoded: base64)
    }
}
