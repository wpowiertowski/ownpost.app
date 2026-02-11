import Foundation
import Observation

/// Orchestrates the full POSSE flow: publish to Ghost first (canonical), then syndicate.
/// MainActor-isolated by default (Swift 6.2) since it drives UI state.
@Observable
final class PublishingCoordinator {
    enum PublishState: Sendable {
        case idle
        case publishingToGhost
        case syndicatingToMastodon
        case syndicatingToBluesky
        case completed(results: [SyndicationResult])
        case failed(Error)
    }

    private(set) var state: PublishState = .idle

    private let ghostService: GhostService
    private let mastodonService: MastodonService
    private let blueskyService: BlueskyService
    private let noteStore: NoteStore

    struct PublishOptions: Sendable {
        var publishToGhost: Bool = true
        var syndicateToMastodon: Bool = false
        var syndicateToBluesky: Bool = false
    }

    init(
        ghostService: GhostService,
        mastodonService: MastodonService,
        blueskyService: BlueskyService,
        noteStore: NoteStore
    ) {
        self.ghostService = ghostService
        self.mastodonService = mastodonService
        self.blueskyService = blueskyService
        self.noteStore = noteStore
    }

    /// Full POSSE publish flow
    func publish(note: Note, options: PublishOptions) async {
        var results: [SyndicationResult] = []

        // Step 1: Publish to Ghost (canonical URL)
        if options.publishToGhost {
            state = .publishingToGhost
            do {
                let ghostPost = try await ghostService.publishPost(note: note)
                // Already on MainActor — safe to mutate model objects directly
                note.ghostPostID = ghostPost.id
                note.ghostURL = ghostPost.url
                noteStore.save()
                results.append(.success(.ghost, ghostPost.url))
            } catch {
                state = .failed(error)
                return
            }
        }

        // Step 2: Syndicate to Mastodon (with backlink to Ghost)
        if options.syndicateToMastodon {
            state = .syndicatingToMastodon
            do {
                let status = try await mastodonService.syndicate(note: note)
                note.mastodonStatusID = status.id
                noteStore.save()
                results.append(.success(.mastodon, status.url))
            } catch {
                results.append(.failure(.mastodon, error))
            }
        }

        // Step 3: Syndicate to Bluesky (with backlink to Ghost)
        if options.syndicateToBluesky {
            state = .syndicatingToBluesky
            do {
                let post = try await blueskyService.syndicate(note: note)
                note.blueskyURI = post.uri
                noteStore.save()
                results.append(.success(.bluesky, post.uri))
            } catch {
                results.append(.failure(.bluesky, error))
            }
        }

        state = .completed(results: results)
    }

    func reset() {
        state = .idle
    }
}
