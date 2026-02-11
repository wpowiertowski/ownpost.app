import SwiftUI
import SwiftData

struct NoteListView: View {
    @Binding var selectedNote: Note?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.modifiedAt, order: .reverse) private var notes: [Note]
    @State private var searchText = ""

    var body: some View {
        List(filteredNotes, selection: $selectedNote) { note in
            NoteRowView(note: note)
                .tag(note)
        }
        .searchable(text: $searchText, prompt: "Search notes")
        .navigationTitle("Notes")
        .toolbar {
            NoteListToolbar(onNewNote: createNote)
        }
        .overlay {
            if notes.isEmpty {
                EmptyStateView(message: "No notes yet.\nTap + to create one.")
            }
        }
    }

    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func createNote() {
        let note = Note(title: "Untitled")
        modelContext.insert(note)
        try? modelContext.save()
        selectedNote = note
    }
}
