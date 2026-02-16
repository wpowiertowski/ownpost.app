import SwiftUI
import SwiftData

enum NoteSortOrder: String, CaseIterable {
    case modified = "Modified"
    case created = "Created"
    case published = "Published"
}

struct NoteListView: View {
    @Binding var selectedNote: Note?
    @Binding var columnVisibility: NavigationSplitViewVisibility
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    @State private var searchText = ""
    @State private var noteToRename: Note?
    @State private var renameTitle = ""
    @AppStorage("noteSortOrder") private var sortOrder: NoteSortOrder = .created

    var body: some View {
        List(sortedNotes, selection: $selectedNote) { note in
            NoteRowView(note: note, sortOrder: sortOrder)
                .tag(note)
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
                        Label("Rename", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        delete(note: note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .overlay {
            if notes.isEmpty {
                EmptyStateView(message: "No notes yet")
            }
        }
        .searchable(text: $searchText, prompt: "Search")
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNote) {
                    Label("New Note", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            if columnVisibility != .detailOnly {
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Sort By", selection: $sortOrder) {
                            ForEach(NoteSortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
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

    private var sortedNotes: [Note] {
        let filtered = searchText.isEmpty ? Array(notes) : notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.body.localizedCaseInsensitiveContains(searchText)
        }

        return filtered.sorted { a, b in
            switch sortOrder {
            case .modified:
                return a.modifiedAt > b.modifiedAt
            case .created:
                return a.createdAt > b.createdAt
            case .published:
                let aDate = a.publishedAt ?? .distantPast
                let bDate = b.publishedAt ?? .distantPast
                return aDate > bDate
            }
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
