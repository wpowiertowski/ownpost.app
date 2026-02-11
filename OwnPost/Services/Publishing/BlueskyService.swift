import Foundation

actor BlueskyService {
    private let auth: BlueskyAuthManager
    private let http: HTTPClient
    private let baseURL = URL(string: "https://bsky.social/xrpc")!

    init(auth: BlueskyAuthManager = BlueskyAuthManager(), http: HTTPClient = .shared) {
        self.auth = auth
        self.http = http
    }

    struct BlueskyPost: Sendable {
        let uri: String
        let cid: String
    }

    struct BlueskyBlob: Codable, Sendable {
        let ref: BlobRef
        let mimeType: String
        let size: Int

        struct BlobRef: Codable, Sendable {
            let link: String

            enum CodingKeys: String, CodingKey {
                case link = "$link"
            }
        }

        enum CodingKeys: String, CodingKey {
            case ref = "ref"
            case mimeType
            case size
        }
    }

    struct BlueskyFacet: Encodable {
        let index: ByteSlice
        let features: [Feature]

        struct ByteSlice: Encodable {
            let byteStart: Int
            let byteEnd: Int
        }

        struct Feature: Encodable {
            let type: String
            let uri: String

            enum CodingKeys: String, CodingKey {
                case type = "$type"
                case uri
            }
        }
    }

    /// Create a post on Bluesky linking back to Ghost (POSSE)
    func syndicate(note: Note) async throws -> BlueskyPost {
        let token = try await auth.getAccessToken()
        let did = try await auth.getDID()

        // Upload images as blobs first
        var images: [[String: Any]] = []
        for attachment in note.imageAttachments {
            let blob = try await uploadBlob(data: attachment.imageData, token: token)
            images.append([
                "alt": attachment.altText ?? "",
                "image": [
                    "$type": "blob",
                    "ref": ["$link": blob.ref.link],
                    "mimeType": blob.mimeType,
                    "size": blob.size
                ]
            ])
        }

        // Build text with POSSE link
        let excerpt = MarkdownExporter.excerpt(note.body, maxLength: 250)
        var text = "\(note.title)\n\n\(excerpt)"
        if let ghostURL = note.ghostURL {
            text += "\n\n\(ghostURL)"
        }

        // Build facets for link detection
        let facets = buildLinkFacets(text: text, url: note.ghostURL)

        // Build record
        var record: [String: Any] = [
            "$type": "app.bsky.feed.post",
            "text": text,
            "createdAt": ISO8601DateFormatter().string(from: .now)
        ]

        if !facets.isEmpty {
            record["facets"] = facets.map { facet in
                [
                    "index": ["byteStart": facet.index.byteStart, "byteEnd": facet.index.byteEnd],
                    "features": facet.features.map { feature in
                        ["$type": feature.type, "uri": feature.uri] as [String: Any]
                    }
                ] as [String: Any]
            }
        }

        if !images.isEmpty {
            record["embed"] = [
                "$type": "app.bsky.embed.images",
                "images": images
            ] as [String: Any]
        }

        let body: [String: Any] = [
            "repo": did,
            "collection": "app.bsky.feed.post",
            "record": record
        ]

        let url = baseURL.appendingPathComponent("com.atproto.repo.createRecord")
        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, _) = try await URLSession.shared.data(for: request)

        struct CreateRecordResponse: Decodable {
            let uri: String
            let cid: String
        }

        let response = try JSONDecoder().decode(CreateRecordResponse.self, from: data)
        return BlueskyPost(uri: response.uri, cid: response.cid)
    }

    /// Upload a blob (image) to Bluesky
    func uploadBlob(data: Data, token: String) async throws -> BlueskyBlob {
        let url = baseURL.appendingPathComponent("com.atproto.repo.uploadBlob")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, _) = try await URLSession.shared.data(for: request)

        struct BlobResponse: Decodable {
            let blob: BlueskyBlob
        }

        let response = try JSONDecoder().decode(BlobResponse.self, from: responseData)
        return response.blob
    }

    /// Build facets for link detection in Bluesky rich text
    func buildLinkFacets(text: String, url: String?) -> [BlueskyFacet] {
        guard let url, !url.isEmpty else { return [] }

        let textData = text.data(using: .utf8)!
        guard let range = text.range(of: url) else { return [] }

        let byteStart = text[text.startIndex..<range.lowerBound].data(using: .utf8)!.count
        let byteEnd = byteStart + url.data(using: .utf8)!.count

        return [
            BlueskyFacet(
                index: .init(byteStart: byteStart, byteEnd: byteEnd),
                features: [
                    .init(type: "app.bsky.richtext.facet#link", uri: url)
                ]
            )
        ]
    }
}
