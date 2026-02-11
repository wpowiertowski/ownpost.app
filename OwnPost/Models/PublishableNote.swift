import Foundation

struct PublishableNote: Sendable {
    struct Image: Sendable {
        let filename: String
        let imageData: Data
        let altText: String?
    }

    let title: String
    let body: String
    let tags: [String]
    let ghostURL: String?
    let imageAttachments: [Image]
}
