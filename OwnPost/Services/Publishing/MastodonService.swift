import Foundation

actor MastodonService {
    private let auth: MastodonAuthManager
    private let http: HTTPClient

    init(auth: MastodonAuthManager = MastodonAuthManager(), http: HTTPClient = .shared) {
        self.auth = auth
        self.http = http
    }

    struct MastodonStatus: Codable, Sendable {
        let id: String
        let url: String?
    }

    /// Post a status linking back to the Ghost canonical URL (POSSE)
    func syndicate(note: PublishableNote) async throws -> MastodonStatus {
        let token = try await auth.getAccessToken()
        let instanceURL = try await auth.getInstanceURL()

        // Upload images first if any
        var mediaIDs: [String] = []
        for attachment in note.imageAttachments {
            let mediaID = try await uploadMedia(
                data: attachment.imageData,
                altText: attachment.altText,
                token: token,
                instanceURL: instanceURL
            )
            mediaIDs.append(mediaID)
        }

        // Build status text with POSSE link
        let excerpt = MarkdownExporter.excerpt(note.body, maxLength: 200)
        var statusText = "\(note.title)\n\n\(excerpt)"
        if let ghostURL = note.ghostURL {
            statusText += "\n\n\(ghostURL)"
        }

        struct StatusRequest: Encodable {
            let status: String
            let media_ids: [String]
        }

        let url = instanceURL.appendingPathComponent("api/v1/statuses")
        let response: MastodonStatus = try await http.request(
            url,
            method: "POST",
            headers: ["Authorization": "Bearer \(token)"],
            body: StatusRequest(
                status: statusText,
                media_ids: mediaIDs
            ),
            responseType: MastodonStatus.self
        )

        return response
    }

    /// Upload media with alt text
    private func uploadMedia(
        data: Data,
        altText: String?,
        token: String,
        instanceURL: URL
    ) async throws -> String {
        let url = instanceURL.appendingPathComponent("api/v2/media")

        // Build multipart body with file and description
        let boundary = UUID().uuidString
        var body = Data()

        // File part
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        // Alt text part
        if let altText, !altText.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append(
                "Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!
            )
            body.append(altText.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = body

        let (responseData, _) = try await URLSession.shared.data(for: request)

        struct MediaResponse: Decodable {
            let id: String
        }

        let media = try JSONDecoder().decode(MediaResponse.self, from: responseData)
        return media.id
    }
}
