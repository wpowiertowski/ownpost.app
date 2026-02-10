import SwiftData

struct SwiftDataContainer {
    static func create() -> ModelContainer {
        let schema = Schema([
            Note.self,
            PublishRecord.self,
            ImageAttachment.self
        ])
        let config = ModelConfiguration(
            "OwnPost",
            schema: schema,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
