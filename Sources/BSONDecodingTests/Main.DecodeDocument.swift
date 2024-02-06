import BSONDecoding
import Testing

extension Main
{
    enum DecodeDocument
    {
    }
}
extension Main.DecodeDocument:TestBattery
{
    static
    func run(tests:TestGroup)
    {

        let degenerate:BSON.Document =
        [
            "present": .null,
            "present": true,
        ]
        let bson:BSON.Document =
        [
            "present": .null,
            "inhabited": true,
        ]

        Self.run(tests / "key-not-unique", bson: degenerate,
            catching: BSON.DocumentKeyError<BSON.Key>.duplicate("present"))
        {
            try $0["not-present"].decode(to: Bool.self)
        }

        Self.run(tests / "key-not-present", bson: bson,
            catching: BSON.DocumentKeyError<BSON.Key>.undefined("not-present"))
        {
            try $0["not-present"].decode(to: Bool.self)
        }

        Self.run(tests / "key-matching", bson: bson,
            to: true)
        {
            try $0["inhabited"].decode(to: Bool.self)
        }

        Self.run(tests / "key-not-matching", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(invalid: .bool),
                in: "inhabited"))
        {
            try $0["inhabited"].decode(to: String.self)
        }

        Self.run(tests / "key-not-matching-inhabited", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.TypecastError<Bool>.init(invalid: .null),
                in: "present"))
        {
            try $0["present"].decode(to: Bool.self)
        }

        Self.run(tests / "key-inhabited", bson: bson,
            to: .some(true))
        {
            try $0["inhabited"].decode(to: Bool?.self)
        }

        Self.run(tests / "key-null", bson: bson,
            to: nil)
        {
            try $0["present"].decode(to: Bool?.self)
        }

        Self.run(tests / "key-optional", bson: bson,
            to: nil)
        {
            try $0["not-present"]?.decode(to: Bool.self)
        }

        Self.run(tests / "key-optional-null", bson: bson,
            to: .some(.none))
        {
            try $0["present"]?.decode(to: Bool?.self)
        }

        Self.run(tests / "key-optional-inhabited", bson: bson,
            to: .some(.some(true)))
        {
            try $0["inhabited"]?.decode(to: Bool?.self)
        }

        // should throw an error instead of returning nil.
        Self.run(tests / "key-optional-not-inhabited", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.TypecastError<Bool>.init(invalid: .null),
                in: "present"))
        {
            try $0["present"]?.decode(to: Bool.self)
        }
    }
}
