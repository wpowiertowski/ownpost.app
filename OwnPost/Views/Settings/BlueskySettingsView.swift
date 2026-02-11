import SwiftUI

struct BlueskySettingsView: View {
    @State private var handle = ""
    @State private var appPassword = ""
    @State private var isConnected = false
    @State private var isConnecting = false
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        Form {
            Section {
                TextField("Handle", text: $handle, prompt: Text("yourname.bsky.social"))
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .disabled(isConnected)

                SecureField("App Password", text: $appPassword, prompt: Text("xxxx-xxxx-xxxx-xxxx"))
                    .autocorrectionDisabled()
                    .disabled(isConnected)
            } header: {
                Text("Bluesky Account")
            } footer: {
                Text("Use an App Password from bsky.app → Settings → App Passwords. Never use your main password.")
            }

            Section {
                if isConnected {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Button("Disconnect", role: .destructive) {
                        disconnect()
                    }
                } else {
                    Button(action: connect) {
                        if isConnecting {
                            ProgressView()
                        } else {
                            Text("Sign In")
                        }
                    }
                    .disabled(handle.isEmpty || appPassword.isEmpty || isConnecting)
                }
            }

            if let statusMessage {
                Section {
                    Label(statusMessage, systemImage: isError ? "xmark.circle" : "checkmark.circle")
                        .foregroundStyle(isError ? .red : .green)
                }
            }
        }
        .navigationTitle("Bluesky")
        .task {
            await loadCredentials()
        }
    }

    private func connect() {
        isConnecting = true
        statusMessage = nil

        Task {
            do {
                let auth = BlueskyAuthManager()
                try await auth.createSession(identifier: handle, password: appPassword)
                isConnected = true
                statusMessage = "Connected successfully"
                isError = false
                appPassword = "" // Clear from memory
            } catch {
                statusMessage = error.localizedDescription
                isError = true
            }
            isConnecting = false
        }
    }

    private func disconnect() {
        Task {
            try? await KeychainManager.shared.delete(key: BlueskyCredentials.keychainKey)
            isConnected = false
            handle = ""
            appPassword = ""
            statusMessage = nil
        }
    }

    private func loadCredentials() async {
        do {
            if let credentials = try await KeychainManager.shared.read(
                key: BlueskyCredentials.keychainKey,
                as: BlueskyCredentials.self
            ) {
                handle = credentials.handle
                isConnected = true
            }
        } catch {
            // No saved credentials
        }
    }
}
