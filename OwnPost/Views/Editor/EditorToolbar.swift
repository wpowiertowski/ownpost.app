import SwiftUI

struct EditorToolbar: ToolbarContent {
    @Binding var showPreview: Bool
    let onProofread: () -> Void
    let onPublish: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                showPreview.toggle()
            } label: {
                Label(
                    showPreview ? "Edit" : "Preview",
                    systemImage: showPreview ? "pencil" : "eye"
                )
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])

            Menu {
                Button("Proofread", systemImage: "text.magnifyingglass", action: onProofread)
                Button("Generate Alt Text", systemImage: "photo.badge.checkmark") {
                    // Handled via ImageAttachmentView
                }
            } label: {
                Label("AI", systemImage: "brain")
            }

            Button(action: onPublish) {
                Label("Publish", systemImage: "paperplane")
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
        }
    }
}
