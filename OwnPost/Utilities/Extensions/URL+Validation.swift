import Foundation

extension URL {
    /// Check if this URL has a valid HTTPS scheme
    var isHTTPS: Bool {
        scheme?.lowercased() == "https"
    }

    /// Check if this URL looks like a valid web URL
    var isValidWebURL: Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        guard scheme == "http" || scheme == "https" else { return false }
        guard host != nil else { return false }
        return true
    }
}

extension String {
    /// Check if this string is a plausibly valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.isValidWebURL
    }
}
