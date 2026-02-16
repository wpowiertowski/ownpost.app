import Foundation
import Testing
@testable import OwnPost

// MARK: - Mock URL Protocol

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    nonisolated override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    nonisolated override func stopLoading() {}
}

// MARK: - Tests

@Suite(.serialized)
struct HTTPClientTests {

    private func makeSUT() -> HTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return HTTPClient(session: session)
    }

    private struct TestResponse: Codable, Equatable, Sendable {
        let message: String
        let count: Int
    }

    private struct TestBody: Codable, Sendable {
        let name: String
    }

    private let testURL = URL(string: "https://api.example.com/test")!

    @Test func successfulGETRequest() async throws {
        let client = makeSUT()
        let expected = TestResponse(message: "hello", count: 42)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode(expected)
            return (response, data)
        }

        let result: TestResponse = try await client.request(
            testURL,
            responseType: TestResponse.self
        )
        #expect(result == expected)
    }

    @Test func successfulPOSTWithBody() async throws {
        let client = makeSUT()
        let expected = TestResponse(message: "created", count: 1)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 201,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode(expected)
            return (response, data)
        }

        let result: TestResponse = try await client.request(
            testURL,
            method: "POST",
            body: TestBody(name: "test"),
            responseType: TestResponse.self
        )
        #expect(result == expected)
    }

    @Test func customHeadersAreSent() async throws {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = try JSONEncoder().encode(TestResponse(message: "ok", count: 0))
            return (response, data)
        }

        let _: TestResponse = try await client.request(
            testURL,
            headers: ["Authorization": "Bearer token123", "X-Custom": "value"],
            responseType: TestResponse.self
        )
    }

    @Test func httpErrorThrows() async {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: TestResponse = try await client.request(
                testURL,
                responseType: TestResponse.self
            )
            Issue.record("Expected HTTPError.httpError")
        } catch let error as HTTPClient.HTTPError {
            if case .httpError(let statusCode, _) = error {
                #expect(statusCode == 404)
            } else {
                Issue.record("Expected httpError, got \(error)")
            }
        } catch {
            Issue.record("Expected HTTPError.httpError, got \(error)")
        }
    }

    @Test func serverErrorThrows() async {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{\"error\":\"internal\"}".utf8))
        }

        do {
            let _: TestResponse = try await client.request(
                testURL,
                responseType: TestResponse.self
            )
            Issue.record("Expected HTTPError.httpError")
        } catch let error as HTTPClient.HTTPError {
            if case .httpError(let statusCode, let body) = error {
                #expect(statusCode == 500)
                #expect(body != nil)
            } else {
                Issue.record("Expected httpError, got \(error)")
            }
        } catch {
            Issue.record("Expected HTTPError.httpError, got \(error)")
        }
    }

    @Test func decodingFailureThrows() async {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{\"wrong\":\"shape\"}".utf8))
        }

        do {
            let _: TestResponse = try await client.request(
                testURL,
                responseType: TestResponse.self
            )
            Issue.record("Expected HTTPError.decodingFailed")
        } catch let error as HTTPClient.HTTPError {
            if case .decodingFailed = error {
                // Expected
            } else {
                Issue.record("Expected decodingFailed, got \(error)")
            }
        } catch {
            Issue.record("Expected HTTPError.decodingFailed, got \(error)")
        }
    }

    @Test func uploadSuccess() async throws {
        let client = makeSUT()
        let fileData = Data("image content".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{\"url\":\"https://cdn.example.com/photo.jpg\"}".utf8))
        }

        let result = try await client.upload(
            testURL,
            fileData: fileData,
            filename: "photo.jpg",
            mimeType: "image/jpeg"
        )
        #expect(!result.isEmpty)
    }

    @Test func uploadHTTPErrorThrows() async {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 413,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        do {
            _ = try await client.upload(
                testURL,
                fileData: Data("data".utf8),
                filename: "file.jpg",
                mimeType: "image/jpeg"
            )
            Issue.record("Expected HTTPError.httpError")
        } catch let error as HTTPClient.HTTPError {
            if case .httpError(let statusCode, _) = error {
                #expect(statusCode == 413)
            } else {
                Issue.record("Expected httpError, got \(error)")
            }
        } catch {
            Issue.record("Expected HTTPError.httpError, got \(error)")
        }
    }

    @Test func uploadCustomHeaders() async throws {
        let client = makeSUT()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{}".utf8))
        }

        _ = try await client.upload(
            testURL,
            headers: ["Authorization": "Ghost token"],
            fileData: Data("img".utf8),
            filename: "f.jpg",
            mimeType: "image/jpeg"
        )
    }
}
