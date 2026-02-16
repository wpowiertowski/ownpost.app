import Foundation

struct MarkdownParser {
    /// Parse markdown to native AttributedString for SwiftUI rendering
    static func parse(_ markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
    }

    /// Parse with full block-level syntax support
    static func parseFull(_ markdown: String) -> AttributedString {
        let html = MarkdownExporter.toHTML(markdown)
        let document = """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {
              margin: 0;
              font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
              font-size: 14px;
              line-height: 1.45;
            }
          </style>
        </head>
        <body>\(html)</body>
        </html>
        """

        guard let data = document.data(using: .utf8) else {
            return AttributedString(markdown)
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard
            let nsAttributed = try? NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
        else {
            return AttributedString(markdown)
        }

        return AttributedString(nsAttributed)
    }
}
