import SwiftUI

struct EmptyStateView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("OwnPost", systemImage: "note.text")
        } description: {
            Text(message)
        }
    }
}
