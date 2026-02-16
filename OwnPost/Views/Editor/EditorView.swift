import SwiftUI

struct EditorView: View {
    @Bindable var note: Note
    @State private var showPreview = false
    @State private var showPublishSheet = false
    @State private var showProofreading = false
    @State private var editorView = MarkdownEditorView(text: .constant(""))
    @State private var lastSavedTitle = ""
    @State private var lastSavedBody = ""
    @State private var hasLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Untitled", text: $note.title)
                .font(Constants.Design.monoLargeTitle)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if showPreview {
                MarkdownPreviewView(markdown: note.body)
                    .padding(.horizontal)
            } else {
                MarkdownEditorView(text: $note.body)
                    .padding(.horizontal)
            }
        }
        #if os(iOS)
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
        .onAppear {
            lastSavedTitle = note.title
            lastSavedBody = note.body
            hasLoaded = true
        }
        .onChange(of: note.id) {
            lastSavedTitle = note.title
            lastSavedBody = note.body
        }
        .onChange(of: note.body) { _, newValue in
            guard hasLoaded, newValue != lastSavedBody else { return }
            note.modifiedAt = .now
            lastSavedBody = newValue
        }
        .onChange(of: note.title) { _, newValue in
            guard hasLoaded, newValue != lastSavedTitle else { return }
            note.modifiedAt = .now
            lastSavedTitle = newValue
        }
    }
}
