import Foundation

enum Constants {
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
