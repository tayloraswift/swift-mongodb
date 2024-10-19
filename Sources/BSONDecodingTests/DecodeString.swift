import BSONDecoding
import Testing

@Suite
struct DecodeString
{
    private
    let bson:BSON.DocumentDecoder<BSON.Key>

    init() throws
    {
        let bson:BSON.Document =
        [
            "string": "e\u{0301}e\u{0301}",
            "character": "e\u{0301}",
            "unicode-scalar": "e",
        ]

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeString
{
    @Test
    func UnicodeScalarFromString() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}e\u{0301}"),
            in: "string"))
        {
            try self.bson["string"].decode(to: Unicode.Scalar.self)
        }
    }

    @Test
    func UnicodeScalarFromCharacter() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}"),
            in: "character"))
        {
            try self.bson["character"].decode(to: Unicode.Scalar.self)
        }
    }

    @Test
    func UnicodeScalarFromUnicodeScalar() throws
    {
        #expect(try "e" == self.bson["unicode-scalar"].decode(to: Unicode.Scalar.self))
    }

    @Test
    func CharacterFromString() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ValueError<String, Character>.init(invalid: "e\u{0301}e\u{0301}"),
            in: "string"))
        {
            try self.bson["string"].decode(to: Character.self)
        }
    }

    @Test
    func CharacterFromCharacter() throws
    {
        #expect(try "e\u{0301}" == self.bson["character"].decode(to: Character.self))
    }

    @Test
    func StringFromString() throws
    {
        #expect(try "e\u{0301}e\u{0301}" == self.bson["string"].decode(to: String.self))
    }
}
