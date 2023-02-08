import Testing
import BSONDecoding

@main 
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        do
        {
            let bson:BSON.Document<[UInt8]> =
            [
                "null": .null,
                "max": .max,
                "min": .min,
            ]

            (tests / "null").do
            {
                let dictionary:BSON.Dictionary<ArraySlice<UInt8>> = try bson.dictionary()
                let _:Never? = try dictionary["null"].decode(to: Never?.self)
            }
            TestDecoding(tests / "max", bson: bson, to: .init())
            {
                try $0["max"].decode(to: BSON.Max.self)
            }
            TestDecoding(tests / "min", bson: bson, to: .init())
            {
                try $0["min"].decode(to: BSON.Min.self)
            }
        }
        do
        {
            let tests:TestGroup = tests / "numeric"

            let bson:BSON.Document<[UInt8]> =
            [
                "int32": .int32(0x7fff_ffff),
                "int64": .int64(0x7fff_ffff_ffff_ffff),
                "uint64": .uint64(0x7fff_ffff_ffff_ffff),
            ]

            TestDecoding(tests / "int32-to-uint8", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.IntegerOverflowError<UInt8>.int32(0x7fff_ffff),
                    in: "int32"))
            {
                try $0["int32"].decode(to: UInt8.self)
            }

            TestDecoding(tests / "int32-to-int32", bson: bson,
                to: 0x7fff_ffff)
            {
                try $0["int32"].decode(to: Int32.self)
            }

            TestDecoding(tests / "int32-to-int", bson: bson,
                to: 0x7fff_ffff)
            {
                try $0["int32"].decode(to: Int.self)
            }

            TestDecoding(tests / "int64-to-int", bson: bson,
                to: 0x7fff_ffff_ffff_ffff)
            {
                try $0["int64"].decode(to: Int.self)
            }
            TestDecoding(tests / "uint64-to-int", bson: bson,
                to: 0x7fff_ffff_ffff_ffff)
            {
                try $0["uint64"].decode(to: Int.self)
            }
        }

        do
        {
            let tests:TestGroup = tests / "tuple"

            let bson:BSON.Document<[UInt8]> =
            [
                "none":     [],
                "two":      ["a", "b"],
                "three":    ["a", "b", "c"],
                "four":     ["a", "b", "c", "d"],

                "heterogenous": ["a", "b", 0, "d"],
            ]

            TestDecoding(tests / "none-to-two", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 0, expected: 2),
                    in: "none"))
            {
                try $0["none"].decode
                {
                    try $0.array(count: 2)
                }
            }

            TestDecoding(tests / "two-to-two", bson: bson,
                to: ["a", "b"])
            {
                try $0["two"].decode
                {
                    try $0.array(count: 2).elements
                }
            }

            TestDecoding(tests / "three-to-two", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 3, expected: 2),
                    in: "three"))
            {
                try $0["three"].decode
                {
                    try $0.array(count: 2)
                }
            }

            TestDecoding(tests / "three-by-two", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 3, expected: nil),
                    in: "three"))
            {
                try $0["three"].decode
                {
                    try $0.array { $0.isMultiple(of: 2) }
                }
            }

            TestDecoding(tests / "four-by-two", bson: bson,
                to: ["a", "b", "c", "d"])
            {
                try $0["four"].decode
                {
                    (try $0.array { $0.isMultiple(of: 2) }).elements
                }
            }

            TestDecoding(tests / "map", bson: bson,
                to: ["a", "b", "c", "d"])
            {
                try $0["four"].decode(to: [String].self)
            }

            TestDecoding(tests / "map-invalid", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.DecodingError<Int>.init(
                        BSON.TypecastError<BSON.UTF8<ArraySlice<UInt8>>>.init(invalid: .int64),
                        in: 2),
                    in: "heterogenous"))
            {
                try $0["heterogenous"].decode(to: [String].self)
            }

            TestDecoding(tests / "element", bson: bson, to: "c")
            {
                try $0["four"].decode
                {
                    try (try $0.array { 2 < $0 })[2].decode(to: String.self)
                }
            }

            TestDecoding(tests / "element-invalid", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.DecodingError<Int>.init(
                        BSON.TypecastError<BSON.UTF8<ArraySlice<UInt8>>>.init(invalid: .int64),
                        in: 2),
                    in: "heterogenous"))
            {
                try $0["heterogenous"].decode
                {
                    try (try $0.array { 2 < $0 })[2].decode(to: String.self)
                }
            }
        }
        
        do
        {
            let tests:TestGroup = tests / "document"

            let degenerate:BSON.Document<[UInt8]> =
            [
                "present": .null,
                "present": true,
            ]
            let bson:BSON.Document<[UInt8]> =
            [
                "present": .null,
                "inhabited": true,
            ]

            TestDecoding(tests / "key-not-unique", bson: degenerate,
                catching: BSON.DictionaryKeyError.duplicate("present"))
            {
                try $0["not-present"].decode(to: Bool.self)
            }

            TestDecoding(tests / "key-not-present", bson: bson,
                catching: BSON.DictionaryKeyError.undefined("not-present"))
            {
                try $0["not-present"].decode(to: Bool.self)
            }

            TestDecoding(tests / "key-matching", bson: bson,
                to: true)
            {
                try $0["inhabited"].decode(to: Bool.self)
            }

            TestDecoding(tests / "key-not-matching", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.TypecastError<BSON.UTF8<ArraySlice<UInt8>>>.init(invalid: .bool),
                    in: "inhabited"))
            {
                try $0["inhabited"].decode(to: String.self)
            }

            TestDecoding(tests / "key-not-matching-inhabited", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.TypecastError<Bool>.init(invalid: .null),
                    in: "present"))
            {
                try $0["present"].decode(to: Bool.self)
            }

            TestDecoding(tests / "key-inhabited", bson: bson,
                to: .some(true))
            {
                try $0["inhabited"].decode(to: Bool?.self)
            }

            TestDecoding(tests / "key-null", bson: bson,
                to: nil)
            {
                try $0["present"].decode(to: Bool?.self)
            }

            TestDecoding(tests / "key-optional", bson: bson,
                to: nil)
            {
                try $0["not-present"]?.decode(to: Bool.self)
            }

            TestDecoding(tests / "key-optional-null", bson: bson,
                to: .some(.none))
            {
                try $0["present"]?.decode(to: Bool?.self)
            }

            TestDecoding(tests / "key-optional-inhabited", bson: bson,
                to: .some(.some(true)))
            {
                try $0["inhabited"]?.decode(to: Bool?.self)
            }

            // should throw an error instead of returning [`nil`]().
            TestDecoding(tests / "key-optional-not-inhabited", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.TypecastError<Bool>.init(invalid: .null),
                    in: "present"))
            {
                try $0["present"]?.decode(to: Bool.self)
            }
        }

        do
        {
            let tests:TestGroup = tests / "binary" / "md5"

            let md5:BSON.Binary<[UInt8]> = .init(subtype: .md5,
                slice: [0xff, 0xfe, 0xfd])
            let bson:BSON.Document<[UInt8]> =
            [
                "md5": .binary(md5),
            ]

            tests.do
            {
                let dictionary:BSON.Dictionary<ArraySlice<UInt8>> = try bson.dictionary()
                let decoded:BSON.Binary<ArraySlice<UInt8>> = try dictionary["md5"].decode(
                    as: BSON.Binary<ArraySlice<UInt8>>.self)
                {
                    $0
                }
                tests.expect(true: md5 == decoded)
            }
        }

        do
        {
            let tests:TestGroup = tests / "losslessstringconvertible"

            let bson:BSON.Document<[UInt8]> =
            [
                "string": "e\u{0301}e\u{0301}",
                "character": "e\u{0301}",
                "unicode-scalar": "e",
            ]

            TestDecoding(tests / "unicode-scalar-from-string", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}e\u{0301}"),
                    in: "string"))
            {
                try $0["string"].decode(to: Unicode.Scalar.self)
            }
            TestDecoding(tests / "unicode-scalar-from-character", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}"),
                    in: "character"))
            {
                try $0["character"].decode(to: Unicode.Scalar.self)
            }
            TestDecoding(tests / "unicode-scalar", bson: bson,
                to: "e")
            {
                try $0["unicode-scalar"].decode(to: Unicode.Scalar.self)
            }

            TestDecoding(tests / "character-from-string", bson: bson,
                catching: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Character>.init(invalid: "e\u{0301}e\u{0301}"),
                    in: "string"))
            {
                try $0["string"].decode(to: Character.self)
            }
            TestDecoding(tests / "character", bson: bson,
                to: "e\u{0301}")
            {
                try $0["character"].decode(to: Character.self)
            }
            
            TestDecoding(tests / "string", bson: bson,
                to: "e\u{0301}e\u{0301}")
            {
                try $0["string"].decode(to: String.self)
            }
        }
    }
}
