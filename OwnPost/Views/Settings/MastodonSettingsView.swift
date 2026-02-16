import SwiftUI
import AuthenticationServices

struct MastodonSettingsView: View {
    @State private var instanceURL = ""
    @State private var isConnected = false
    @State private var isConnecting = false
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        Form {
            Section {
                TextField("Instance URL", text: $instanceURL, prompt: Text("https://mastodon.social"))
                    .font(Constants.Design.monoBody)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .disabled(isConnected)
            } header: {
                Text("Instance")
                    .font(Constants.Design.monoCaption)
            } footer: {
                Text("Enter your Mastodon instance URL to connect via OAuth.")
                    .font(Constants.Design.monoCaption)
            }

            Section {
                if isConnected {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .font(Constants.Design.monoBody)
                        .foregroundStyle(Constants.Design.accentColor)

                    Button("Disconnect", role: .destructive) {
                        disconnect()
                    }
                    .font(Constants.Design.monoBody)
                } else {
                    Button(action: connect) {
                        if isConnecting {
                            ProgressView()
                        } else {
                            Text("Connect with OAuth")
                                .font(Constants.Design.monoBody)
                        }
                    }
                    .disabled(instanceURL.isEmpty || isConnecting)
                }
            }

            if let statusMessage {
                Section {
                    Label(statusMessage, systemImage: isError ? "xmark.circle" : "checkmark.circle")
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(isError ? .red : Constants.Design.accentColor)
                }
            }
        }
        .navigationTitle("Mastodon")
        .task {
            await loadCredentials()
        }
    }

    private func connect() {
        isConnecting = true
        statusMessage = nil

        Task {
            do {
                guard let url = URL(string: instanceURL) else {
                    throw URLError(.badURL)
                }
                let auth = MastodonAuthManager()
                try await auth.registerApp(instanceURL: url)
                // OAuth flow would be triggered here via ASWebAuthenticationSession
                statusMessage = "App registered. OAuth flow needs to be completed."
                isError = false
            } catch {
                statusMessage = error.localizedDescription
                isError = true
            }
            isConnecting = false
        }
    }

    private func disconnect() {
        Task {
            try? await KeychainManager.shared.delete(key: MastodonCredentials.keychainKey)
            isConnected = false
            instanceURL = ""
            statusMessage = nil
        }
    }

    private func loadCredentials() async {
        do {
            if let credentials = try await KeychainManager.shared.read(
                key: MastodonCredentials.keychainKey,
                as: MastodonCredentials.self
            ) {
                instanceURL = credentials.instanceURL.absoluteString
                isConnected = true
            }
        } catch {
            // No saved credentials
        }
    }
}
