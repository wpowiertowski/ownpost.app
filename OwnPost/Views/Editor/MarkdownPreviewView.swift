import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String

    var body: some View {
        ScrollView {
            Text(attributedContent)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }

    private var attributedContent: AttributedString {
        MarkdownParser.parseFull(markdown)
    }
}
