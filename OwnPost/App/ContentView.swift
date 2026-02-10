import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedNote: Note?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            NoteListView(selectedNote: $selectedNote)
        } detail: {
            if let note = selectedNote {
                EditorView(note: note)
            } else {
                EmptyStateView(message: "Select or create a note")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(SwiftDataContainer.create())
}
