import Testing
@testable import TONWalletKit

@Suite("TONMnemonic Tests")
struct TONMnemonicTests {

    @Test("init() creates 24 empty strings")
    func initDefault() {
        let sut = TONMnemonic()

        #expect(sut.value.count == 24)
        #expect(sut.value.allSatisfy { $0.isEmpty })
    }

    @Test("init(value:) with 12 words fills first 12 and pads rest")
    func initWith12Words() {
        let words = (1...12).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.value.count == 24)
        for i in 0..<12 {
            #expect(sut.value[i] == "word\(i + 1)")
        }
        for i in 12..<24 {
            #expect(sut.value[i] == "")
        }
    }

    @Test("init(value:) with 24 words fills all")
    func initWith24Words() {
        let words = (1...24).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.value.count == 24)
        for i in 0..<24 {
            #expect(sut.value[i] == "word\(i + 1)")
        }
    }

    @Test("init(value:) with more than 24 words caps at 24")
    func initWithMoreThan24Words() {
        let words = (1...30).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.value.count == 24)
        #expect(sut.value[23] == "word24")
    }

    @Test("init(string:) splits by space")
    func initString() {
        let input = "one two three four five six seven eight nine ten eleven twelve"
        let sut = TONMnemonic(string: input)

        #expect(sut.value[0] == "one")
        #expect(sut.value[11] == "twelve")
        #expect(sut.value[12] == "")
    }

    @Test("isFilled returns false for empty mnemonic")
    func isFilledEmpty() {
        let sut = TONMnemonic()

        #expect(sut.isFilled == false)
    }

    @Test("isFilled returns true for 12 contiguous words")
    func isFilled12Words() {
        let words = (1...12).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.isFilled == true)
    }

    @Test("isFilled returns true for 24 contiguous words")
    func isFilled24Words() {
        let words = (1...24).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.isFilled == true)
    }

    @Test("isFilled returns false for partial fill (5 words)")
    func isFilledPartial() {
        let words = (1...5).map { "word\($0)" }
        let sut = TONMnemonic(value: words)

        #expect(sut.isFilled == false)
    }

    @Test("update(word:at:) updates correct index")
    func updateValid() {
        var sut = TONMnemonic()
        sut.update(word: "hello", at: 3)

        #expect(sut.value[3] == "hello")
    }

    @Test("update(word:at:) out of range does not crash")
    func updateOutOfRange() {
        var sut = TONMnemonic()
        sut.update(word: "hello", at: 100)

        #expect(sut.value.count == 24)
    }
}
