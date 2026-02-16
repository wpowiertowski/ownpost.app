import SwiftUI

struct GhostSettingsView: View {
    @State private var apiURL = ""
    @State private var adminAPIKey = ""
    @State private var isSaving = false
    @State private var statusMessage: String?
    @State private var isError = false

    var body: some View {
        Form {
            Section {
                TextField("Ghost URL", text: $apiURL, prompt: Text("https://yourblog.ghost.io"))
                    .font(Constants.Design.monoBody)
                    #if os(iOS)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()

                SecureField("Admin API Key", text: $adminAPIKey, prompt: Text("64-character hex key"))
                    .font(Constants.Design.monoBody)
                    .autocorrectionDisabled()
            } header: {
                Text("Configuration")
                    .font(Constants.Design.monoCaption)
            } footer: {
                Text("Find your Admin API key in Ghost Admin → Settings → Integrations.")
                    .font(Constants.Design.monoCaption)
            }

            Section {
                Button(action: saveCredentials) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .font(Constants.Design.monoBody)
                    }
                }
                .disabled(apiURL.isEmpty || adminAPIKey.isEmpty || isSaving)
            }

            if let statusMessage {
                Section {
                    Label(statusMessage, systemImage: isError ? "xmark.circle" : "checkmark.circle")
                        .font(Constants.Design.monoCaption)
                        .foregroundStyle(isError ? .red : Constants.Design.accentColor)
                }
            }
        }
        .navigationTitle("Ghost")
        .task {
            await loadCredentials()
        }
    }

    private func saveCredentials() {
        isSaving = true
        statusMessage = nil

        Task {
            do {
                guard let url = URL(string: apiURL) else {
                    throw URLError(.badURL)
                }
                let auth = GhostAuthManager()
                try await auth.configure(apiURL: url, adminAPIKey: adminAPIKey)
                statusMessage = "Credentials saved successfully"
                isError = false
            } catch {
                statusMessage = error.localizedDescription
                isError = true
            }
            isSaving = false
        }
    }

    private func loadCredentials() async {
        do {
            if let credentials = try await KeychainManager.shared.read(
                key: GhostCredentials.keychainKey,
                as: GhostCredentials.self
            ) {
                apiURL = credentials.apiURL.absoluteString
                adminAPIKey = credentials.adminAPIKey
            }
        } catch {
            // No saved credentials — that's fine
        }
    }
}
