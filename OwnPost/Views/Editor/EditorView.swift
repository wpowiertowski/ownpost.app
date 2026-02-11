import SwiftUI

struct EditorView: View {
    @Bindable var note: Note
    @State private var showPreview = false
    @State private var showPublishSheet = false
    @State private var showProofreading = false
    @State private var editorView = MarkdownEditorView(text: .constant(""))
    private let contentHorizontalPadding: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                TextField("Untitled", text: $note.title)
                    .font(.system(.largeTitle, design: .default, weight: .bold))
                    .foregroundStyle(.primary)
                    .textFieldStyle(.plain)

                Text(note.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, contentHorizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 6)

            Group {
                if showPreview {
                    MarkdownPreviewView(markdown: note.body)
                } else {
                    MarkdownEditorView(text: $note.body)
                }
            }
            .padding(.horizontal, contentHorizontalPadding)
        }
        #if os(iOS)
        .navigationTitle(note.title.isEmpty ? "Untitled" : note.title)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            EditorToolbar(
                showPreview: $showPreview,
                onBold: { editorView.toggleBold() },
                onItalic: { editorView.toggleItalic() },
                onProofread: { showProofreading = true },
                onPublish: { showPublishSheet = true }
            )
        }
        .sheet(isPresented: $showPublishSheet) {
            PublishSheet(note: note)
        }
        .sheet(isPresented: $showProofreading) {
            ProofreadingSheet(note: note)
        }
        .onChange(of: note.body) {
            note.modifiedAt = .now
        }
        .onChange(of: note.title) {
            note.modifiedAt = .now
        }
    }
}
