import SwiftData
import Foundation
import Observation

@Observable
final class NoteStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(
        sortedBy sortDescriptor: SortDescriptor<Note> = SortDescriptor(\.modifiedAt, order: .reverse)
    ) -> [Note] {
        let descriptor = FetchDescriptor<Note>(sortBy: [sortDescriptor])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func search(query: String) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate<Note> { note in
                note.title.localizedStandardContains(query) ||
                note.body.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func create(title: String, body: String = "") -> Note {
        let note = Note(title: title, body: body)
        modelContext.insert(note)
        save()
        return note
    }

    func delete(_ note: Note) {
        modelContext.delete(note)
        save()
    }

    func save() {
        try? modelContext.save()
    }
}
