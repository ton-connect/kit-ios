import Testing
import Foundation
@testable import TONWalletKit

@Suite("TONBridgeEventMetadata Tests")
struct TONBridgeEventMetadataTests {

    @Test("init stores value")
    func initStoresValue() {
        let data = Data("hello".utf8)
        let sut = TONBridgeEventMetadata(value: data)
        #expect(sut.value == data)
    }

    @Test("stringValue returns UTF-8 string")
    func stringValueReturnsUTF8String() {
        let sut = TONBridgeEventMetadata(value: Data("test-string".utf8))
        #expect(sut.stringValue == "test-string")
    }

    @Test("stringValue returns nil for invalid UTF-8")
    func stringValueReturnsNilForInvalidUTF8() {
        let invalidUTF8 = Data([0xFF, 0xFE])
        let sut = TONBridgeEventMetadata(value: invalidUTF8)
        #expect(sut.stringValue == nil)
    }

    @Test("Decodes from JSON string")
    func decodesFromJSONString() throws {
        let json = "\"some-metadata\""
        let data = Data(json.utf8)
        let sut = try JSONDecoder().decode(TONBridgeEventMetadata.self, from: data)
        #expect(sut.stringValue == "some-metadata")
    }

    @Test("Encodes to JSON string")
    func encodesToJSONString() throws {
        let sut = TONBridgeEventMetadata(value: Data("encoded-value".utf8))
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(String?.self, from: data)
        #expect(decoded == "encoded-value")
    }

    @Test("Round-trip encode and decode preserves value")
    func roundTripPreservesValue() throws {
        let original = TONBridgeEventMetadata(value: Data("round-trip".utf8))
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TONBridgeEventMetadata.self, from: encoded)
        #expect(decoded.value == original.value)
    }

    @Test("Extract decodes JSON to Decodable type")
    func extractDecodesJSON() throws {
        let json = "{\"name\":\"Alice\",\"age\":30}"
        let sut = TONBridgeEventMetadata(value: Data(json.utf8))
        let person: Person = try sut.extract()
        #expect(person.name == "Alice")
        #expect(person.age == 30)
    }

    @Test("Extract throws for invalid JSON")
    func extractThrowsForInvalidJSON() {
        let sut = TONBridgeEventMetadata(value: Data("not-json".utf8))
        #expect(throws: (any Error).self) {
            let _: Person = try sut.extract()
        }
    }

    @Test("Extract decodes array")
    func extractDecodesArray() throws {
        let json = "[1,2,3]"
        let sut = TONBridgeEventMetadata(value: Data(json.utf8))
        let values: [Int] = try sut.extract()
        #expect(values == [1, 2, 3])
    }
}

private struct Person: Decodable {
    let name: String
    let age: Int
}
