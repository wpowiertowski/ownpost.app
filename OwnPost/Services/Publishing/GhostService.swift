import Foundation

actor GhostService {
    private let auth: GhostAuthManager
    private let http: HTTPClient

    init(auth: GhostAuthManager = GhostAuthManager(), http: HTTPClient = .shared) {
        self.auth = auth
        self.http = http
    }

    struct GhostPost: Codable, Sendable {
        let id: String
        let url: String?
        let title: String?
        let status: String?
    }

    enum GhostPostStatus: String, Sendable {
        case published
        case draft
    }

    private struct GhostPostsResponse: Codable {
        let posts: [GhostPost]
    }

    private struct GhostPostsRequest: Encodable {
        let posts: [GhostPostBody]
    }

    private struct GhostPostBody: Encodable {
        let title: String
        let html: String
        let status: String
        let tags: [GhostTagBody]
    }

    private struct GhostTagBody: Encodable {
        let name: String
    }

    /// Publish a note as a Ghost post
    func publishPost(note: Note, status: GhostPostStatus = .published) async throws -> GhostPost {
        let token = try await auth.generateToken()
        let baseURL = try await auth.getAPIURL()
        let html = MarkdownExporter.toHTML(note.body)

        // Upload images first
        for attachment in note.imageAttachments {
            _ = try await uploadImage(data: attachment.imageData, filename: attachment.filename)
        }

        let url = baseURL.appendingPathComponent("ghost/api/admin/posts/")
        let body = GhostPostsRequest(posts: [
            GhostPostBody(
                title: note.title,
                html: html,
                status: status.rawValue,
                tags: note.tags.map { GhostTagBody(name: $0) }
            )
        ])

        let response: GhostPostsResponse = try await http.request(
            url,
            method: "POST",
            headers: ["Authorization": "Ghost \(token)"],
            body: body,
            responseType: GhostPostsResponse.self
        )

        guard let post = response.posts.first else {
            throw GhostError.noPostReturned
        }
        return post
    }

    /// Upload an image to Ghost
    func uploadImage(data: Data, filename: String) async throws -> String {
        let token = try await auth.generateToken()
        let baseURL = try await auth.getAPIURL()
        let url = baseURL.appendingPathComponent("ghost/api/admin/images/upload/")

        let responseData = try await http.upload(
            url,
            headers: ["Authorization": "Ghost \(token)"],
            fileData: data,
            filename: filename,
            mimeType: "image/\(filename.hasSuffix(".png") ? "png" : "jpeg")",
            fieldName: "file"
        )

        struct ImageResponse: Codable {
            struct Image: Codable {
                let url: String
            }
            let images: [Image]
        }

        let decoded = try JSONDecoder().decode(ImageResponse.self, from: responseData)
        guard let imageURL = decoded.images.first?.url else {
            throw GhostError.imageUploadFailed
        }
        return imageURL
    }

    /// Update an existing post
    func updatePost(ghostID: String, note: Note) async throws -> GhostPost {
        let token = try await auth.generateToken()
        let baseURL = try await auth.getAPIURL()
        let html = MarkdownExporter.toHTML(note.body)

        let url = baseURL.appendingPathComponent("ghost/api/admin/posts/\(ghostID)/")
        let body = GhostPostsRequest(posts: [
            GhostPostBody(
                title: note.title,
                html: html,
                status: "published",
                tags: note.tags.map { GhostTagBody(name: $0) }
            )
        ])

        let response: GhostPostsResponse = try await http.request(
            url,
            method: "PUT",
            headers: ["Authorization": "Ghost \(token)"],
            body: body,
            responseType: GhostPostsResponse.self
        )

        guard let post = response.posts.first else {
            throw GhostError.noPostReturned
        }
        return post
    }

    enum GhostError: Error, LocalizedError {
        case noPostReturned
        case imageUploadFailed

        var errorDescription: String? {
            switch self {
            case .noPostReturned: "Ghost API did not return a post"
            case .imageUploadFailed: "Failed to upload image to Ghost"
            }
        }
    }
}
