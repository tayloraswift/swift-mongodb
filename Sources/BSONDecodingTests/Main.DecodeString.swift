import BSONDecoding
import Testing

extension Main
{
    enum DecodeString
    {
    }
}
extension Main.DecodeString:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let bson:BSON.Document =
        [
            "string": "e\u{0301}e\u{0301}",
            "character": "e\u{0301}",
            "unicode-scalar": "e",
        ]

        Self.run(tests / "unicode-scalar-from-string", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}e\u{0301}"),
                in: "string"))
        {
            try $0["string"].decode(to: Unicode.Scalar.self)
        }
        Self.run(tests / "unicode-scalar-from-character", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}"),
                in: "character"))
        {
            try $0["character"].decode(to: Unicode.Scalar.self)
        }
        Self.run(tests / "unicode-scalar", bson: bson,
            to: "e")
        {
            try $0["unicode-scalar"].decode(to: Unicode.Scalar.self)
        }

        Self.run(tests / "character-from-string", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ValueError<String, Character>.init(invalid: "e\u{0301}e\u{0301}"),
                in: "string"))
        {
            try $0["string"].decode(to: Character.self)
        }
        Self.run(tests / "character", bson: bson,
            to: "e\u{0301}")
        {
            try $0["character"].decode(to: Character.self)
        }

        Self.run(tests / "string", bson: bson,
            to: "e\u{0301}e\u{0301}")
        {
            try $0["string"].decode(to: String.self)
        }
    }
}
