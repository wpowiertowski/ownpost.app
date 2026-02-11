import SwiftUI
import SwiftData

struct NoteListView: View {
    @Binding var selectedNote: Note?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.modifiedAt, order: .reverse) private var notes: [Note]
    @State private var searchText = ""
    @State private var noteToRename: Note?
    @State private var renameTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            List(filteredNotes, selection: $selectedNote) { note in
                NoteRowView(note: note)
                    .tag(note)
                    #if os(iOS)
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            startRename(note: note)
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            delete(note: note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            startRename(note: note)
                        } label: {
                            Label("Rename Note", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            delete(note: note)
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    }
                    #endif
                    #if os(macOS)
                    .contextMenu {
                        Button {
                            startRename(note: note)
                        } label: {
                            Label("Rename Note", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            delete(note: note)
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    }
                    #endif
            }
            .overlay {
                if notes.isEmpty {
                    EmptyStateView(message: "No notes yet.\nUse + to create one.")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search notes")
        .navigationTitle("")
        .toolbar {
            #if os(macOS)
            ToolbarItem(placement: .navigation) {
                Button(action: createNote) {
                    ZStack {
                        Circle()
                            .fill(.primary.opacity(0.14))
                        Circle()
                            .strokeBorder(.primary.opacity(0.26), lineWidth: 1)
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .help("New Note")
                .keyboardShortcut("n", modifiers: .command)
            }
            #else
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNote) {
                    Image(systemName: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            #endif
        }
        .alert(
            "Rename Note",
            isPresented: Binding(
                get: { noteToRename != nil },
                set: { isPresented in
                    if !isPresented {
                        noteToRename = nil
                    }
                }
            )
        ) {
            TextField("Title", text: $renameTitle)
            Button("Cancel", role: .cancel) {
                noteToRename = nil
            }
            Button("Rename") {
                commitRename()
            }
        } message: {
            Text("Enter a new title for this note.")
        }
        #if os(macOS)
        .onDeleteCommand(perform: deleteSelectedNote)
        #endif
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

    private func delete(note: Note) {
        if selectedNote?.id == note.id {
            selectedNote = nil
        }
        modelContext.delete(note)
        try? modelContext.save()
    }

    private func deleteSelectedNote() {
        guard let selectedNote else { return }
        delete(note: selectedNote)
    }

    private func startRename(note: Note) {
        noteToRename = note
        renameTitle = note.title
    }

    private func commitRename() {
        guard let note = noteToRename else { return }
        let trimmed = renameTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        note.title = trimmed.isEmpty ? "Untitled" : trimmed
        note.modifiedAt = .now
        try? modelContext.save()
        noteToRename = nil
    }
}
