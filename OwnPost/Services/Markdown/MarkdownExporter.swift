import Foundation
import Markdown

struct MarkdownExporter {
    /// Convert markdown to HTML for Ghost publishing
    nonisolated static func toHTML(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLFormatter()
        return htmlVisitor.visit(document)
    }

    /// Extract a plain text excerpt for social media syndication
    nonisolated static func excerpt(_ markdown: String, maxLength: Int = 280) -> String {
        let plain = markdown
            .replacingOccurrences(
                of: #"[#*_`\[\]()!>]"#,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if plain.count <= maxLength {
            return plain
        }
        let truncated = plain.prefix(maxLength - 1)
        // Try to break at a word boundary
        if let lastSpace = truncated.lastIndex(of: " ") {
            return String(truncated[..<lastSpace]) + "\u{2026}"
        }
        return String(truncated) + "\u{2026}"
    }
}

// MARK: - HTML Formatter using swift-markdown

private struct HTMLFormatter: MarkupWalker {
    private var html = ""

    nonisolated mutating func visit(_ document: Document) -> String {
        html = ""
        for child in document.children {
            visit(child)
        }
        return html
    }

    nonisolated mutating func visitHeading(_ heading: Heading) {
        let level = heading.level
        html += "<h\(level)>"
        for child in heading.children {
            visit(child)
        }
        html += "</h\(level)>\n"
    }

    nonisolated mutating func visitParagraph(_ paragraph: Paragraph) {
        html += "<p>"
        for child in paragraph.children {
            visit(child)
        }
        html += "</p>\n"
    }

    nonisolated mutating func visitText(_ text: Markdown.Text) {
        html += escapeHTML(text.string)
    }

    nonisolated mutating func visitEmphasis(_ emphasis: Emphasis) {
        html += "<em>"
        for child in emphasis.children {
            visit(child)
        }
        html += "</em>"
    }

    nonisolated mutating func visitStrong(_ strong: Strong) {
        html += "<strong>"
        for child in strong.children {
            visit(child)
        }
        html += "</strong>"
    }

    nonisolated mutating func visitLink(_ link: Markdown.Link) {
        html += "<a href=\"\(link.destination ?? "")\">"
        for child in link.children {
            visit(child)
        }
        html += "</a>"
    }

    nonisolated mutating func visitImage(_ image: Markdown.Image) {
        let alt = image.plainText
        let src = image.source ?? ""
        html += "<img src=\"\(src)\" alt=\"\(escapeHTML(alt))\" />"
    }

    nonisolated mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
        let lang = codeBlock.language ?? ""
        if lang.isEmpty {
            html += "<pre><code>"
        } else {
            html += "<pre><code class=\"language-\(lang)\">"
        }
        html += escapeHTML(codeBlock.code)
        html += "</code></pre>\n"
    }

    nonisolated mutating func visitInlineCode(_ inlineCode: InlineCode) {
        html += "<code>\(escapeHTML(inlineCode.code))</code>"
    }

    nonisolated mutating func visitBlockQuote(_ blockQuote: BlockQuote) {
        html += "<blockquote>\n"
        for child in blockQuote.children {
            visit(child)
        }
        html += "</blockquote>\n"
    }

    nonisolated mutating func visitUnorderedList(_ unorderedList: UnorderedList) {
        html += "<ul>\n"
        for child in unorderedList.children {
            visit(child)
        }
        html += "</ul>\n"
    }

    nonisolated mutating func visitOrderedList(_ orderedList: OrderedList) {
        html += "<ol>\n"
        for child in orderedList.children {
            visit(child)
        }
        html += "</ol>\n"
    }

    nonisolated mutating func visitListItem(_ listItem: ListItem) {
        html += "<li>"
        for child in listItem.children {
            visit(child)
        }
        html += "</li>\n"
    }

    nonisolated mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) {
        html += "<hr />\n"
    }

    nonisolated mutating func visitSoftBreak(_ softBreak: SoftBreak) {
        html += "\n"
    }

    nonisolated mutating func visitLineBreak(_ lineBreak: LineBreak) {
        html += "<br />\n"
    }

    private nonisolated func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    nonisolated mutating func visit(_ markup: any Markup) {
        if let heading = markup as? Heading {
            visitHeading(heading)
        } else if let paragraph = markup as? Paragraph {
            visitParagraph(paragraph)
        } else if let text = markup as? Markdown.Text {
            visitText(text)
        } else if let emphasis = markup as? Emphasis {
            visitEmphasis(emphasis)
        } else if let strong = markup as? Strong {
            visitStrong(strong)
        } else if let link = markup as? Markdown.Link {
            visitLink(link)
        } else if let image = markup as? Markdown.Image {
            visitImage(image)
        } else if let codeBlock = markup as? CodeBlock {
            visitCodeBlock(codeBlock)
        } else if let inlineCode = markup as? InlineCode {
            visitInlineCode(inlineCode)
        } else if let blockQuote = markup as? BlockQuote {
            visitBlockQuote(blockQuote)
        } else if let unorderedList = markup as? UnorderedList {
            visitUnorderedList(unorderedList)
        } else if let orderedList = markup as? OrderedList {
            visitOrderedList(orderedList)
        } else if let listItem = markup as? ListItem {
            visitListItem(listItem)
        } else if let thematicBreak = markup as? ThematicBreak {
            visitThematicBreak(thematicBreak)
        } else if let softBreak = markup as? SoftBreak {
            visitSoftBreak(softBreak)
        } else if let lineBreak = markup as? LineBreak {
            visitLineBreak(lineBreak)
        } else {
            for child in markup.children {
                visit(child)
            }
        }
    }
}
