import SwiftUI
import Observation

@Observable
final class AppState {
    var selectedNote: Note?
    var isEditorFocused: Bool = false
    var searchText: String = ""

    // Publishing state
    var isPublishing: Bool = false

    // AI availability
    var isAIAvailable: Bool = false

    static let shared = AppState()

    private init() {}
}
