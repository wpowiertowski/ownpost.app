# OwnPost

OwnPost is a SwiftUI app for writing notes in Markdown, publishing canonical posts to Ghost, and syndicating to Mastodon and Bluesky (POSSE workflow).

## Features

- Markdown editing and preview
- Local persistence with SwiftData
- Publishing to Ghost Admin API
- Syndication to Mastodon and Bluesky
- Optional on-device AI helpers (proofreading and alt text)
- iOS and macOS targets

## Tech Stack

- Swift 6.2
- SwiftUI + Observation
- SwiftData
- `swift-markdown` for Markdown parsing/export
- FoundationModels (on supported devices)

## Requirements

- Xcode 26+
- iOS 26 / macOS 26 SDK
- Swift 6.2 toolchain
- `xcodegen` (if you want to regenerate the Xcode project from `project.yml`)

## Getting Started

### 1) Clone and enter the repo

```bash
git clone https://github.com/wpowiertowski/ownpost.app.git
cd ownpost.app
```

### 2) Build with Swift Package Manager

```bash
swift build --scratch-path .build
```

### 3) Generate Xcode project (optional)

```bash
xcodegen generate
open OwnPost.xcodeproj
```

If you already have a generated project, you can open it directly in Xcode and run on iOS Simulator or macOS.

## Configuration

Publishing credentials are configured inside the app settings:

- Ghost: Admin API URL + Admin API key (`{id}:{secret}`)
- Mastodon: instance URL + OAuth flow
- Bluesky: handle/email + app password

Credentials are stored via Keychain services in `OwnPost/Services/Keychain/KeychainManager.swift`.

## Project Structure

- `OwnPost/App` app entry and root state
- `OwnPost/Models` SwiftData models and publish snapshots
- `OwnPost/Services` AI, networking, persistence, markdown, publishing
- `OwnPost/Views` editor, AI sheets, publishing UI, settings, shared components
- `project.yml` XcodeGen project definition
- `Package.swift` SwiftPM build definition

## Notes

- SwiftPM build is configured to process app resources (`Assets.xcassets`, `Localizable.xcstrings`).
- `Info.plist` and entitlements are excluded from SwiftPM target compilation and used via Xcode project settings.

## License

See `LICENSE`.
