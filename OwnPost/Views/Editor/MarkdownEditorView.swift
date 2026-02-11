import SwiftUI

/// Rich text markdown editor using iOS 26 / macOS 26 TextEditor with AttributedString.
/// Supports inline formatting (bold, italic) via native text selection and formatting controls.
struct MarkdownEditorView: View {
    @Binding var text: String
    @Environment(\.fontResolutionContext) private var fontResolutionContext
    @State private var selection = AttributedTextSelection()
    @State private var attributedText = AttributedString()

    var body: some View {
        TextEditor(text: $attributedText, selection: $selection)
            .font(.system(.body, design: .monospaced))
            .padding()
            .onAppear {
                attributedText = AttributedString(text)
            }
            .onChange(of: attributedText) {
                // Sync attributed text back to the plain markdown string
                text = String(attributedText.characters)
            }
            .onChange(of: text) {
                // Only sync if external change (e.g., proofreading accept)
                let current = String(attributedText.characters)
                if current != text {
                    attributedText = AttributedString(text)
                }
            }
    }

    // MARK: - Formatting Actions

    func toggleBold() {
        attributedText.transformAttributes(in: &selection) { container in
            let currentFont = container.font ?? .default
            let resolved = currentFont.resolve(in: fontResolutionContext)
            container.font = currentFont.bold(!resolved.isBold)
        }
    }

    func toggleItalic() {
        attributedText.transformAttributes(in: &selection) { container in
            let currentFont = container.font ?? .default
            let resolved = currentFont.resolve(in: fontResolutionContext)
            container.font = currentFont.italic(!resolved.isItalic)
        }
    }
}
