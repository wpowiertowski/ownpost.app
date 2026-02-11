import Foundation
import Testing
@testable import OwnPost

@MainActor
struct GhostCredentialsTests {

    @Test func keyIDParsing() {
        let creds = GhostCredentials(
            apiURL: URL(string: "https://blog.example.com")!,
            adminAPIKey: "abc123:deadbeef0123456789"
        )
        #expect(creds.keyID == "abc123")
    }

    @Test func keySecretParsing() {
        let creds = GhostCredentials(
            apiURL: URL(string: "https://blog.example.com")!,
            adminAPIKey: "abc123:deadbeef0123456789"
        )
        #expect(creds.keySecret == "deadbeef0123456789")
    }

    @Test func invalidKeyNilID() {
        let creds = GhostCredentials(
            apiURL: URL(string: "https://blog.example.com")!,
            adminAPIKey: "no-colon-here"
        )
        #expect(creds.keyID == nil)
        #expect(creds.keySecret == nil)
    }

    @Test func keychainKeyConstant() {
        #expect(GhostCredentials.keychainKey == "ghost.credentials")
    }

    @Test func codableRoundTrip() throws {
        let original = GhostCredentials(
            apiURL: URL(string: "https://blog.example.com")!,
            adminAPIKey: "myid:abcdef1234567890"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GhostCredentials.self, from: data)
        #expect(decoded.apiURL == original.apiURL)
        #expect(decoded.adminAPIKey == original.adminAPIKey)
    }

    @Test func keyWithMultipleColons() {
        let creds = GhostCredentials(
            apiURL: URL(string: "https://blog.example.com")!,
            adminAPIKey: "id:secret:extra"
        )
        // split(separator:) splits at every colon, so count > 2 → nil
        #expect(creds.keyID == nil)
        #expect(creds.keySecret == nil)
    }
}
