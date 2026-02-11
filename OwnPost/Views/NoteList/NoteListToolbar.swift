import SwiftUI

struct NoteListToolbar: ToolbarContent {
    let onNewNote: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: onNewNote) {
                Label("New Note", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}
