import SwiftUI
import SwiftData

@main
struct OwnPostApp: App {
    let container = SwiftDataContainer.create()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)

        #if os(macOS)
        Settings {
            SettingsView()
        }
        .modelContainer(container)
        #endif
    }
}
