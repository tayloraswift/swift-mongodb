import BSONDecoding
import Testing

extension Main
{
    enum DecodeList
    {
    }
}
extension Main.DecodeList:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let bson:BSON.DocumentView =
        [
            "none":     [],
            "two":      ["a", "b"],
            "three":    ["a", "b", "c"],
            "four":     ["a", "b", "c", "d"],

            "heterogenous": ["a", "b", 0, "d"],
        ]

        Self.run(tests / "none-to-two", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ShapeError.init(invalid: 0, expected: .length(2)),
                in: "none"))
        {
            try $0["none"].decode
            {
                try $0.shape.expect(length: 2)
            }
        }

        Self.run(tests / "two-to-two", bson: bson,
            to: ["a", "b"])
        {
            try $0["two"].decode
            {
                try $0.shape.expect(length: 2)
                return try $0.map { try $0.decode(to: String.self) }
            }
        }

        Self.run(tests / "three-to-two", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ShapeError.init(invalid: 3, expected: .length(2)),
                in: "three"))
        {
            try $0["three"].decode
            {
                try $0.shape.expect(length: 2)
            }
        }

        Self.run(tests / "three-by-two", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.ShapeError.init(invalid: 3, expected: .multiple(of: 2)),
                in: "three"))
        {
            try $0["three"].decode
            {
                try $0.shape.expect(multipleOf: 2)
            }
        }

        Self.run(tests / "four-by-two", bson: bson,
            to: ["a", "b", "c", "d"])
        {
            try $0["four"].decode
            {
                try $0.shape.expect(multipleOf: 2)
                return try $0.map { try $0.decode(to: String.self) }
            }
        }

        Self.run(tests / "map", bson: bson,
            to: ["a", "b", "c", "d"])
        {
            try $0["four"].decode(to: [String].self)
        }

        Self.run(tests / "map-invalid", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.DecodingError<Int>.init(
                    BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(
                        invalid: .int32),
                    in: 2),
                in: "heterogenous"))
        {
            try $0["heterogenous"].decode(to: [String].self)
        }

        Self.run(tests / "element", bson: bson, to: "c")
        {
            try $0["four"].decode
            {
                try $0.shape.expect { 2 < $0 }
                return try $0[2].decode(to: String.self)
            }
        }

        Self.run(tests / "element-invalid", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.DecodingError<Int>.init(
                    BSON.TypecastError<BSON.UTF8View<ArraySlice<UInt8>>>.init(
                        invalid: .int32),
                    in: 2),
                in: "heterogenous"))
        {
            try $0["heterogenous"].decode
            {
                try $0.shape.expect { 2 < $0 }
                return try $0[2].decode(to: String.self)
            }
        }
    }
}
