import SwiftUI

struct SettingsView: View {
    var body: some View {
        #if os(macOS)
        TabView {
            GhostSettingsView()
                .tabItem {
                    Label("Ghost", systemImage: "globe")
                }
            MastodonSettingsView()
                .tabItem {
                    Label("Mastodon", systemImage: "at")
                }
            BlueskySettingsView()
                .tabItem {
                    Label("Bluesky", systemImage: "cloud")
                }
            AISettingsView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
        }
        .frame(width: 450, height: 280)
        #else
        NavigationStack {
            Form {
                Section("Publishing") {
                    NavigationLink {
                        GhostSettingsView()
                    } label: {
                        Label("Ghost", systemImage: "globe")
                    }
                    NavigationLink {
                        MastodonSettingsView()
                    } label: {
                        Label("Mastodon", systemImage: "at")
                    }
                    NavigationLink {
                        BlueskySettingsView()
                    } label: {
                        Label("Bluesky", systemImage: "cloud")
                    }
                }

                Section("Features") {
                    NavigationLink {
                        AISettingsView()
                    } label: {
                        Label("AI", systemImage: "sparkles")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        #endif
    }
}
