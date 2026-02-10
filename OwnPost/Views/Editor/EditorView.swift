import SwiftUI

struct EditorView: View {
    @Bindable var note: Note
    @State private var showPreview = false
    @State private var showPublishSheet = false
    @State private var showProofreading = false

    var body: some View {
        Group {
            if showPreview {
                MarkdownPreviewView(markdown: note.body)
            } else {
                MarkdownEditorView(text: $note.body)
            }
        }
        .navigationTitle($note.title)
        #if os(macOS)
        .navigationSubtitle(note.modifiedAt.formatted(.relative(presentation: .named)))
        #endif
        .toolbar {
            EditorToolbar(
                showPreview: $showPreview,
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
