import SwiftUI

struct EditorToolbar: ToolbarContent {
    @Binding var showPreview: Bool
    let onBold: () -> Void
    let onItalic: () -> Void
    let onProofread: () -> Void
    let onPublish: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showPreview.toggle()
            } label: {
                Label(
                    showPreview ? "Edit" : "Preview",
                    systemImage: showPreview ? "pencil" : "eye"
                )
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
        }

        ToolbarSpacer(.fixed)

        ToolbarItemGroup(placement: .primaryAction) {
            Button("Bold", systemImage: "bold", action: onBold)
                .keyboardShortcut("b", modifiers: .command)

            Button("Italic", systemImage: "italic", action: onItalic)
                .keyboardShortcut("i", modifiers: .command)
        }

        ToolbarSpacer(.fixed)

        ToolbarItemGroup(placement: .primaryAction) {
            Menu {
                Button("Proofread", systemImage: "text.magnifyingglass", action: onProofread)
            } label: {
                Label("AI", systemImage: "sparkles")
            }

            Button(action: onPublish) {
                Label("Publish", systemImage: "paperplane.fill")
            }
            .keyboardShortcut(.return, modifiers: [.command, .shift])
        }
    }
}
