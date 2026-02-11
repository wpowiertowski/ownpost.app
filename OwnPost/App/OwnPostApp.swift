import SwiftUI
import SwiftData
#if os(macOS)
import AppKit

final class AppActivationDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
#endif

@main
struct OwnPostApp: App {
    let container = SwiftDataContainer.create()
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppActivationDelegate.self) private var appDelegate
    #endif

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
