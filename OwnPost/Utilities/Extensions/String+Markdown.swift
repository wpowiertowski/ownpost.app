import Foundation

extension String {
    /// Strip markdown formatting to get plain text
    var strippedMarkdown: String {
        self
            .replacingOccurrences(of: #"!\[.*?\]\(.*?\)"#, with: "", options: .regularExpression)  // Images
            .replacingOccurrences(of: #"\[([^\]]+)\]\([^\)]+\)"#, with: "$1", options: .regularExpression)  // Links
            .replacingOccurrences(of: #"#{1,6}\s"#, with: "", options: .regularExpression)  // Headings
            .replacingOccurrences(of: #"\*{1,2}([^*]+)\*{1,2}"#, with: "$1", options: .regularExpression)  // Bold/Italic
            .replacingOccurrences(of: #"`([^`]+)`"#, with: "$1", options: .regularExpression)  // Inline code
            .replacingOccurrences(of: #"^>\s"#, with: "", options: .regularExpression)  // Blockquotes
            .replacingOccurrences(of: #"^[-*+]\s"#, with: "", options: .regularExpression)  // Unordered lists
            .replacingOccurrences(of: #"^\d+\.\s"#, with: "", options: .regularExpression)  // Ordered lists
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Extract the first line as a potential title
    var firstLine: String {
        let lines = self.split(separator: "\n", maxSplits: 1)
        return lines.first.map(String.init) ?? self
    }
}
