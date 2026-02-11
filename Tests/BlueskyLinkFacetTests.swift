import Foundation
import Testing
@testable import OwnPost

struct BlueskyLinkFacetTests {

    private func makeSUT() -> BlueskyService {
        BlueskyService()
    }

    @Test func facetsWithValidURL() async {
        let sut = makeSUT()
        let text = "Check this out\nhttps://blog.example.com/post"
        let facets = await sut.buildLinkFacets(
            text: text,
            url: "https://blog.example.com/post"
        )
        #expect(facets.count == 1)
        #expect(facets[0].features[0].type == "app.bsky.richtext.facet#link")
        #expect(facets[0].features[0].uri == "https://blog.example.com/post")
    }

    @Test func facetsWithNilURL() async {
        let sut = makeSUT()
        let facets = await sut.buildLinkFacets(text: "Some text", url: nil)
        #expect(facets.isEmpty)
    }

    @Test func facetsWithEmptyURL() async {
        let sut = makeSUT()
        let facets = await sut.buildLinkFacets(text: "Some text", url: "")
        #expect(facets.isEmpty)
    }

    @Test func facetsWhenURLNotInText() async {
        let sut = makeSUT()
        let facets = await sut.buildLinkFacets(
            text: "Some text without the link",
            url: "https://nothere.com"
        )
        #expect(facets.isEmpty)
    }

    @Test func facetsByteOffsetsASCII() async {
        let sut = makeSUT()
        // "Hello " is 6 bytes, URL starts at byte 6
        let url = "https://example.com"
        let text = "Hello \(url)"
        let facets = await sut.buildLinkFacets(text: text, url: url)
        #expect(facets.count == 1)
        #expect(facets[0].index.byteStart == 6)
        #expect(facets[0].index.byteEnd == 6 + url.utf8.count)
    }

    @Test func facetsByteOffsetsUnicode() async {
        let sut = makeSUT()
        // Emoji "👋" is 4 bytes in UTF-8, plus space = 5 bytes before URL
        let url = "https://example.com"
        let text = "👋 \(url)"
        let facets = await sut.buildLinkFacets(text: text, url: url)
        #expect(facets.count == 1)
        // "👋" = 4 bytes, " " = 1 byte → byteStart = 5
        #expect(facets[0].index.byteStart == 5)
        #expect(facets[0].index.byteEnd == 5 + url.utf8.count)
    }

    @Test func facetsByteOffsetsMultiByteCharacters() async {
        let sut = makeSUT()
        // "café " = c(1) a(1) f(1) é(2) space(1) = 6 bytes
        let url = "https://example.com"
        let text = "café \(url)"
        let facets = await sut.buildLinkFacets(text: text, url: url)
        #expect(facets.count == 1)
        #expect(facets[0].index.byteStart == 6)
    }

    @Test func facetFeatureType() async {
        let sut = makeSUT()
        let url = "https://example.com/post"
        let facets = await sut.buildLinkFacets(text: "Read: \(url)", url: url)
        #expect(facets.count == 1)
        #expect(facets[0].features.count == 1)
        #expect(facets[0].features[0].type == "app.bsky.richtext.facet#link")
    }
}
