import Foundation
import SwiftUI

enum Constants {
    // MARK: - Design
    enum Design {
        static let accentColor = Color(red: 0.4, green: 0.8, blue: 0.6) // Teal/green accent
        
        // Monospace fonts
        static let monoLargeTitle = Font.system(.largeTitle, design: .monospaced).weight(.medium)
        static let monoTitle = Font.system(.title, design: .monospaced).weight(.medium)
        static let monoTitle2 = Font.system(.title2, design: .monospaced).weight(.medium)
        static let monoTitle3 = Font.system(.title3, design: .monospaced).weight(.medium)
        static let monoHeadline = Font.system(.headline, design: .monospaced)
        static let monoSubheadline = Font.system(.subheadline, design: .monospaced)
        static let monoBody = Font.system(.body, design: .monospaced)
        static let monoCaption = Font.system(.caption, design: .monospaced)
        static let monoCaption2 = Font.system(.caption2, design: .monospaced)
    }
    // MARK: - Keychain Keys
    enum Keychain {
        static let ghostCredentials = GhostCredentials.keychainKey
        static let mastodonCredentials = MastodonCredentials.keychainKey
        static let blueskyCredentials = BlueskyCredentials.keychainKey
    }

    // MARK: - API Endpoints
    enum API {
        static let blueskyBaseURL = URL(string: "https://bsky.social/xrpc")!

        enum Ghost {
            static let postsPath = "ghost/api/admin/posts/"
            static let imagesPath = "ghost/api/admin/images/upload/"
        }

        enum Mastodon {
            static let appsPath = "api/v1/apps"
            static let statusesPath = "api/v1/statuses"
            static let mediaPath = "api/v2/media"
            static let oauthAuthorizePath = "oauth/authorize"
            static let oauthTokenPath = "oauth/token"
        }

        enum Bluesky {
            static let createSession = "com.atproto.server.createSession"
            static let refreshSession = "com.atproto.server.refreshSession"
            static let createRecord = "com.atproto.repo.createRecord"
            static let uploadBlob = "com.atproto.repo.uploadBlob"
        }
    }

    // MARK: - App
    enum App {
        static let name = "OwnPost"
        static let oauthRedirectURI = "ownpost://oauth"
        static let mastodonScopes = "write:statuses write:media"
    }

    // MARK: - Defaults
    enum Defaults {
        static let excerptMaxLength = 280
    }
}
