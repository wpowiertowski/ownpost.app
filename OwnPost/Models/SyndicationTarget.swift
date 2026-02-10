import Foundation

enum SyndicationTarget: String, CaseIterable, Codable, Sendable {
    case ghost
    case mastodon
    case bluesky

    var displayName: String {
        switch self {
        case .ghost: "Ghost"
        case .mastodon: "Mastodon"
        case .bluesky: "Bluesky"
        }
    }
}

enum SyndicationResult: Sendable {
    case success(SyndicationTarget, String?)
    case failure(SyndicationTarget, Error)

    var target: SyndicationTarget {
        switch self {
        case .success(let target, _): target
        case .failure(let target, _): target
        }
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
