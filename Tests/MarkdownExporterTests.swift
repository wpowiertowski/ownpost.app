import Testing
@testable import OwnPost

struct MarkdownExporterTests {

    // MARK: - toHTML

    @Test func emptyInput() {
        let html = MarkdownExporter.toHTML("")
        #expect(html == "")
    }

    @Test func plainParagraph() {
        let html = MarkdownExporter.toHTML("Hello world")
        #expect(html == "<p>Hello world</p>\n")
    }

    @Test func headingLevels() {
        for level in 1...6 {
            let prefix = String(repeating: "#", count: level)
            let html = MarkdownExporter.toHTML("\(prefix) Title")
            #expect(html.contains("<h\(level)>Title</h\(level)>"))
        }
    }

    @Test func boldText() {
        let html = MarkdownExporter.toHTML("**bold**")
        #expect(html.contains("<strong>bold</strong>"))
    }

    @Test func italicText() {
        let html = MarkdownExporter.toHTML("*italic*")
        #expect(html.contains("<em>italic</em>"))
    }

    @Test func linkMarkup() {
        let html = MarkdownExporter.toHTML("[click](https://example.com)")
        #expect(html.contains("<a href=\"https://example.com\">click</a>"))
    }

    @Test func imageMarkup() {
        let html = MarkdownExporter.toHTML("![alt text](https://img.png)")
        #expect(html.contains("<img src=\"https://img.png\" alt=\"alt text\" />"))
    }

    @Test func codeBlockWithoutLanguage() {
        let html = MarkdownExporter.toHTML("```\nlet x = 1\n```")
        #expect(html.contains("<pre><code>"))
        #expect(html.contains("let x = 1"))
        #expect(html.contains("</code></pre>"))
    }

    @Test func codeBlockWithLanguage() {
        let html = MarkdownExporter.toHTML("```swift\nlet x = 1\n```")
        #expect(html.contains("<pre><code class=\"language-swift\">"))
    }

    @Test func inlineCode() {
        let html = MarkdownExporter.toHTML("Use `print()`")
        #expect(html.contains("<code>print()</code>"))
    }

    @Test func blockquote() {
        let html = MarkdownExporter.toHTML("> quoted text")
        #expect(html.contains("<blockquote>"))
        #expect(html.contains("quoted text"))
        #expect(html.contains("</blockquote>"))
    }

    @Test func unorderedList() {
        let html = MarkdownExporter.toHTML("- one\n- two")
        #expect(html.contains("<ul>"))
        #expect(html.contains("<li>"))
        #expect(html.contains("one"))
        #expect(html.contains("two"))
        #expect(html.contains("</ul>"))
    }

    @Test func orderedList() {
        let html = MarkdownExporter.toHTML("1. first\n2. second")
        #expect(html.contains("<ol>"))
        #expect(html.contains("<li>"))
        #expect(html.contains("first"))
        #expect(html.contains("second"))
        #expect(html.contains("</ol>"))
    }

    @Test func thematicBreak() {
        let html = MarkdownExporter.toHTML("---")
        #expect(html.contains("<hr />"))
    }

    @Test func htmlEscapingAngleBracketsAndAmpersand() {
        let html = MarkdownExporter.toHTML("1 < 2 & 3 > 0")
        #expect(html.contains("1 &lt; 2 &amp; 3 &gt; 0"))
    }

    @Test func htmlEscapingQuotes() {
        let html = MarkdownExporter.toHTML("He said \"hello\"")
        #expect(html.contains("“hello”"))
    }

    @Test func nestedBoldInLink() {
        let html = MarkdownExporter.toHTML("[**bold link**](https://example.com)")
        #expect(html.contains("<a href=\"https://example.com\"><strong>bold link</strong></a>"))
    }

    @Test func multipleElements() {
        let md = """
        # Title

        A paragraph with **bold** and *italic*.

        - item
        """
        let html = MarkdownExporter.toHTML(md)
        #expect(html.contains("<h1>Title</h1>"))
        #expect(html.contains("<strong>bold</strong>"))
        #expect(html.contains("<em>italic</em>"))
        #expect(html.contains("<li>"))
    }

    // MARK: - excerpt

    @Test func excerptShortText() {
        let result = MarkdownExporter.excerpt("Short text", maxLength: 280)
        #expect(result == "Short text")
    }

    @Test func excerptExactLength() {
        let text = String(repeating: "a", count: 280)
        let result = MarkdownExporter.excerpt(text, maxLength: 280)
        #expect(result == text)
    }

    @Test func excerptTruncatesAtWordBoundary() {
        let text = "Hello world this is a long sentence that should be truncated"
        let result = MarkdownExporter.excerpt(text, maxLength: 20)
        #expect(result.hasSuffix("\u{2026}"))
        #expect(result.count <= 20)
    }

    @Test func excerptTruncatesWithoutSpaces() {
        let text = String(repeating: "x", count: 300)
        let result = MarkdownExporter.excerpt(text, maxLength: 280)
        #expect(result.hasSuffix("\u{2026}"))
        #expect(result.count == 280)
    }

    @Test func excerptCustomMaxLength() {
        let text = "Hello world this text is short"
        let result = MarkdownExporter.excerpt(text, maxLength: 10)
        #expect(result.count <= 10)
    }

    @Test func excerptEmptyString() {
        let result = MarkdownExporter.excerpt("")
        #expect(result == "")
    }

    @Test func excerptStripsMarkdownCharacters() {
        let result = MarkdownExporter.excerpt("# Heading with **bold**")
        // The excerpt method strips markdown formatting characters
        #expect(!result.contains("#"))
        #expect(!result.contains("**"))
    }
}
