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
                    Label("Mastodon", systemImage: "bubble.left.and.bubble.right")
                }
            BlueskySettingsView()
                .tabItem {
                    Label("Bluesky", systemImage: "cloud")
                }
            AISettingsView()
                .tabItem {
                    Label("AI", systemImage: "brain")
                }
        }
        .frame(width: 450, height: 300)
        #else
        NavigationStack {
            List {
                Section("Publishing") {
                    NavigationLink {
                        GhostSettingsView()
                    } label: {
                        Label("Ghost", systemImage: "globe")
                    }
                    NavigationLink {
                        MastodonSettingsView()
                    } label: {
                        Label("Mastodon", systemImage: "bubble.left.and.bubble.right")
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
                        Label("AI", systemImage: "brain")
                    }
                }
            }
            .navigationTitle("Settings")
        }
        #endif
    }
}
