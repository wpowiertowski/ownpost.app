import Foundation
import Testing
@testable import OwnPost

@MainActor
struct DateFormattingTests {

    @Test func iso8601FormatsCorrectly() {
        // 2024-01-15T10:30:00Z
        let date = Date(timeIntervalSince1970: 1705312200)
        let formatted = DateFormatting.iso8601.string(from: date)
        #expect(formatted.hasPrefix("2024-01-15T"))
        #expect(formatted.contains("T"))
    }

    @Test func iso8601IncludesFractionalSeconds() {
        let formatter = DateFormatting.iso8601
        #expect(formatter.formatOptions.contains(.withFractionalSeconds))
        #expect(formatter.formatOptions.contains(.withInternetDateTime))
    }

    @Test func iso8601RoundTrip() {
        let date = Date(timeIntervalSince1970: 1705312200.123)
        let formatted = DateFormatting.iso8601.string(from: date)
        let parsed = DateFormatting.iso8601.date(from: formatted)
        #expect(parsed != nil)
        // Within 1ms tolerance due to fractional seconds
        #expect(abs((parsed?.timeIntervalSince1970 ?? 0) - date.timeIntervalSince1970) < 0.01)
    }

    @Test func shortDateConfiguration() {
        let formatter = DateFormatting.shortDate
        #expect(formatter.dateStyle == .short)
        #expect(formatter.timeStyle == .none)
    }

    @Test func mediumDateTimeConfiguration() {
        let formatter = DateFormatting.mediumDateTime
        #expect(formatter.dateStyle == .medium)
        #expect(formatter.timeStyle == .short)
    }

    @Test func shortDateProducesNonEmptyOutput() {
        let date = Date(timeIntervalSince1970: 1705312200)
        let result = DateFormatting.shortDate.string(from: date)
        #expect(!result.isEmpty)
    }

    @Test func mediumDateTimeProducesNonEmptyOutput() {
        let date = Date(timeIntervalSince1970: 1705312200)
        let result = DateFormatting.mediumDateTime.string(from: date)
        #expect(!result.isEmpty)
    }
}
