import Security
import Foundation

actor KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.ownpost.app"

    enum KeychainError: Error, LocalizedError {
        case saveFailed(OSStatus)
        case readFailed(OSStatus)
        case deleteFailed(OSStatus)
        case dataConversionFailed

        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                "Keychain save failed with status: \(status)"
            case .readFailed(let status):
                "Keychain read failed with status: \(status)"
            case .deleteFailed(let status):
                "Keychain delete failed with status: \(status)"
            case .dataConversionFailed:
                "Failed to convert data for Keychain operation"
            }
        }
    }

    func save(key: String, data: Data) throws {
        // Delete existing item first
        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func read(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.readFailed(status)
        }

        return result as? Data
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Codable Convenience

    func save<T: Encodable>(key: String, value: T) throws {
        let data = try JSONEncoder().encode(value)
        try save(key: key, data: data)
    }

    func read<T: Codable>(key: String, as type: T.Type) throws -> T? {
        guard let data = try read(key: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
}
