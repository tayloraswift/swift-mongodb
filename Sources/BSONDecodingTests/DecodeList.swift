import BSONDecoding
import Testing

@Suite
struct DecodeList
{
    private
    let bson:BSON.DocumentDecoder<BSON.Key>

    init() throws
    {
        let bson:BSON.Document = [
            "none":     [],
            "two":      ["a", "b"],
            "three":    ["a", "b", "c"],
            "four":     ["a", "b", "c", "d"],

            "heterogenous": ["a", "b", 0, "d"],
        ]

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeList
{
    @Test
    func NoneToTwo() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ShapeError.init(invalid: 0, expected: .length(2)),
            in: "none"))
        {
            try self.bson["none"].decode { try $0.shape.expect(length: 2) }
        }
    }

    @Test
    func TwoToTwo() throws
    {
        #expect(try ["a", "b"] == self.bson["two"].decode
        {
            try $0.shape.expect(length: 2)
            return try $0.map { try $0.decode(to: String.self) }
        })
    }

    @Test
    func ThreeToTwo() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ShapeError.init(invalid: 3, expected: .length(2)),
            in: "three"))
        {
            try self.bson["three"].decode { try $0.shape.expect(length: 2) }
        }
    }

    @Test
    func ThreeByTwo() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.ShapeError.init(invalid: 3, expected: .multiple(of: 2)),
            in: "three"))
        {
            try self.bson["three"].decode { try $0.shape.expect(multipleOf: 2) }
        }
    }

    @Test
    func FourByTwo() throws
    {
        #expect(try ["a", "b", "c", "d"] == self.bson["four"].decode
        {
            _ = try $0.shape.expect(multipleOf: 2)
            return try $0.map { try $0.decode(to: String.self) }
        })
    }

    @Test
    func Map() throws
    {
        #expect(try ["a", "b", "c", "d"] == self.bson["four"].decode())
    }

    @Test
    func MapInvalid() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.DecodingError<Int>.init(
                BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(
                    invalid: .int32),
                in: 2),
            in: "heterogenous"))
        {
            try self.bson["heterogenous"].decode(to: [String].self)
        }
    }

    @Test
    func Element() throws
    {
        #expect(try "c" == self.bson["four"].decode
        {
            try $0.shape.expect { 2 < $0 }
            return try $0[2].decode(to: String.self)
        })
    }

    @Test
    func ElementInvalid() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.DecodingError<Int>.init(
                BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(
                    invalid: .int32),
                in: 2),
            in: "heterogenous"))
        {
            try self.bson["heterogenous"].decode
            {
                try $0.shape.expect { 2 < $0 }
                return try $0[2].decode(to: String.self)
            }
        }
    }
}
