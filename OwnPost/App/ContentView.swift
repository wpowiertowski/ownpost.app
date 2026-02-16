import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedNote: Note?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            NoteListView(selectedNote: $selectedNote, columnVisibility: $columnVisibility)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 400)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
        } detail: {
            if let note = selectedNote {
                EditorView(note: note)
            } else {
                EmptyStateView(message: "Select or create a note")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    ContentView()
        .modelContainer(SwiftDataContainer.create())
}
