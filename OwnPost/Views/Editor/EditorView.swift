import SwiftUI

struct EditorView: View {
    @Bindable var note: Note
    @State private var showPreview = false
    @State private var showPublishSheet = false
    @State private var showProofreading = false
    @State private var editorView = MarkdownEditorView(text: .constant(""))

    var body: some View {
        Group {
            if showPreview {
                MarkdownPreviewView(markdown: note.body)
            } else {
                MarkdownEditorView(text: $note.body)
            }
        }
        .navigationTitle($note.title)
        .navigationSubtitle(note.modifiedAt.formatted(.relative(presentation: .named)))
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
