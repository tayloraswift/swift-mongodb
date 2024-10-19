import BSONDecoding
import Testing

@Suite
struct DecodeDocument
{
    private
    let bson:BSON.DocumentDecoder<BSON.Key>

    init() throws
    {
        let bson:BSON.Document = ["present": .null, "inhabited": true]
        self.bson = try .init(parsing: bson)
    }
}
extension DecodeDocument
{
    @Test
    static func KeyNotUnique() throws
    {
        #expect(throws: BSON.DocumentKeyError<BSON.Key>.duplicate("present"))
        {
            let degenerate:BSON.Document = [
                "present": .null,
                "present": true,
            ]
            let decoder:BSON.DocumentDecoder<BSON.Key> = try .init(parsing: degenerate)
            _ = try decoder["not-present"].decode(to: Bool.self)
        }
    }
}
extension DecodeDocument
{
    @Test
    func KeyNotPresent() throws
    {
        #expect(throws: BSON.DocumentKeyError<BSON.Key>.undefined("not-present"))
        {
            try self.bson["not-present"].decode(to: Bool.self)
        }
    }

    @Test
    func KeyNotMatching() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(invalid: .bool),
            in: "inhabited"))
        {
            try self.bson["inhabited"].decode(to: String.self)
        }
    }

    @Test
    func KeyNotMatchingInhabited() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.TypecastError<Bool>.init(invalid: .null),
            in: "present"))
        {
            try self.bson["present"].decode(to: Bool.self)
        }
    }

    @Test
    func KeyInhabited() throws
    {
        #expect(try true == self.bson["inhabited"].decode(to: Bool?.self))
    }

    @Test
    func KeyMatching() throws
    {
        #expect(try true == self.bson["inhabited"].decode())
    }

    @Test
    func KeyNull() throws
    {
        #expect(try nil == self.bson["present"].decode(to: Bool?.self))
    }

    @Test
    func KeyOptional() throws
    {
        #expect(try nil == self.bson["not-present"]?.decode(to: Bool.self))
    }

    @Test
    func KeyOptionalNull() throws
    {
        #expect(try .some(nil) == self.bson["present"]?.decode(to: Bool?.self))
    }

    @Test
    func KeyOptionalInhabited() throws
    {
        #expect(try true == self.bson["inhabited"]?.decode(to: Bool?.self))
    }

    @Test
    func KeyOptionalNotInhabited() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.TypecastError<Bool>.init(invalid: .null),
            in: "present"))
        {
            try self.bson["present"]?.decode(to: Bool.self)
        }
    }
}
