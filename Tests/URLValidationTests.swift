import Foundation
import Testing
@testable import OwnPost

@MainActor
struct URLValidationTests {

    // MARK: - URL.isHTTPS

    @Test func httpsURLIsHTTPS() {
        let url = URL(string: "https://example.com")!
        #expect(url.isHTTPS == true)
    }

    @Test func httpURLIsNotHTTPS() {
        let url = URL(string: "http://example.com")!
        #expect(url.isHTTPS == false)
    }

    @Test func ftpURLIsNotHTTPS() {
        let url = URL(string: "ftp://example.com")!
        #expect(url.isHTTPS == false)
    }

    // MARK: - URL.isValidWebURL

    @Test func httpsIsValidWebURL() {
        let url = URL(string: "https://example.com")!
        #expect(url.isValidWebURL == true)
    }

    @Test func httpIsValidWebURL() {
        let url = URL(string: "http://example.com")!
        #expect(url.isValidWebURL == true)
    }

    @Test func ftpIsNotValidWebURL() {
        let url = URL(string: "ftp://files.example.com/file")!
        #expect(url.isValidWebURL == false)
    }

    @Test func urlWithPathIsValid() {
        let url = URL(string: "https://example.com/path/to/page")!
        #expect(url.isValidWebURL == true)
    }

    // MARK: - String.isValidURL

    @Test func validHTTPSString() {
        #expect("https://example.com".isValidURL == true)
    }

    @Test func validHTTPString() {
        #expect("http://example.com/page".isValidURL == true)
    }

    @Test func plainTextNotValidURL() {
        #expect("not a url".isValidURL == false)
    }

    @Test func emptyStringNotValidURL() {
        #expect("".isValidURL == false)
    }

    @Test func ftpStringNotValidURL() {
        #expect("ftp://files.example.com".isValidURL == false)
    }

    @Test func urlWithQueryParams() {
        #expect("https://example.com/search?q=test&page=1".isValidURL == true)
    }
}
