import Testing
@testable import OwnPost

@MainActor
struct StringMarkdownTests {

    // MARK: - strippedMarkdown

    @Test func stripImages() {
        let text = "Before ![alt](http://img.png) after"
        #expect(text.strippedMarkdown == "Before  after")
    }

    @Test func stripLinksPreserveText() {
        let text = "Click [here](https://example.com) now"
        #expect(text.strippedMarkdown == "Click here now")
    }

    @Test func stripHeadings() {
        #expect("# Title".strippedMarkdown == "Title")
        #expect("## Subtitle".strippedMarkdown == "Subtitle")
        #expect("### H3".strippedMarkdown == "H3")
    }

    @Test func stripBold() {
        #expect("Some **bold** text".strippedMarkdown == "Some bold text")
    }

    @Test func stripItalic() {
        #expect("Some *italic* text".strippedMarkdown == "Some italic text")
    }

    @Test func stripInlineCode() {
        #expect("Use `code` here".strippedMarkdown == "Use code here")
    }

    @Test func stripBlockquote() {
        #expect("> quoted".strippedMarkdown == "quoted")
    }

    @Test func stripUnorderedListMarkers() {
        #expect("- item".strippedMarkdown == "item")
        #expect("* item".strippedMarkdown == "item")
        #expect("+ item".strippedMarkdown == "item")
    }

    @Test func stripOrderedListMarker() {
        #expect("1. item".strippedMarkdown == "item")
    }

    @Test func plainTextUnchanged() {
        #expect("Just plain text".strippedMarkdown == "Just plain text")
    }

    @Test func emptyStringStaysEmpty() {
        #expect("".strippedMarkdown == "")
    }

    // MARK: - firstLine

    @Test func firstLineMultiline() {
        let text = "First line\nSecond line\nThird line"
        #expect(text.firstLine == "First line")
    }

    @Test func firstLineSingleLine() {
        #expect("Only line".firstLine == "Only line")
    }

    @Test func firstLineEmpty() {
        #expect("".firstLine == "")
    }
}
