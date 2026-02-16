import Foundation
import Testing
@testable import OwnPost

@MainActor
struct SyndicationTargetTests {

    // MARK: - SyndicationTarget

    @Test func displayNames() {
        #expect(SyndicationTarget.ghost.displayName == "Ghost")
        #expect(SyndicationTarget.mastodon.displayName == "Mastodon")
        #expect(SyndicationTarget.bluesky.displayName == "Bluesky")
    }

    @Test func allCasesCount() {
        #expect(SyndicationTarget.allCases.count == 3)
    }

    @Test func rawValues() {
        #expect(SyndicationTarget.ghost.rawValue == "ghost")
        #expect(SyndicationTarget.mastodon.rawValue == "mastodon")
        #expect(SyndicationTarget.bluesky.rawValue == "bluesky")
    }

    @Test func codableRoundTrip() throws {
        let target = SyndicationTarget.mastodon
        let data = try JSONEncoder().encode(target)
        let decoded = try JSONDecoder().decode(SyndicationTarget.self, from: data)
        #expect(decoded == target)
    }

    // MARK: - SyndicationResult

    @Test func successResult() {
        let result = SyndicationResult.success(.ghost, "https://blog.example.com/post")
        #expect(result.isSuccess == true)
        #expect(result.target == .ghost)
    }

    @Test func failureResult() {
        let error = NSError(domain: "test", code: 1)
        let result = SyndicationResult.failure(.mastodon, error)
        #expect(result.isSuccess == false)
        #expect(result.target == .mastodon)
    }

    @Test func successWithNilURL() {
        let result = SyndicationResult.success(.bluesky, nil)
        #expect(result.isSuccess == true)
        #expect(result.target == .bluesky)
    }
}
