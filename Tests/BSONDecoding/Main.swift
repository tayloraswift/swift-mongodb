import Testing
import BSONDecoding

@main 
enum Main:SyncTests
{
    static
    func run(tests:inout Tests)
    {
        tests.group("markers")
        {
            let bson:BSON.Document<[UInt8]> =
            [
                "null": .null,
                "max": .max,
                "min": .min,
            ]

            $0.test(name: "null")
            {
                _ in
                let dictionary:BSON.Dictionary<ArraySlice<UInt8>> = try .init(
                    fields: try bson.parse())
                try dictionary["null"].decode(to: Void.self)
            }
            $0.test(name: "max", decoding: bson,
                expecting: .init())
            {
                try $0["max"].decode(to: BSON.Max.self)
            }
            $0.test(name: "min", decoding: bson,
                expecting: .init())
            {
                try $0["min"].decode(to: BSON.Min.self)
            }
        }
        tests.group("numeric")
        {
            let bson:BSON.Document<[UInt8]> =
            [
                "int32": .int32(0x7fff_ffff),
                "int64": .int64(0x7fff_ffff_ffff_ffff),
                "uint64": .uint64(0x7fff_ffff_ffff_ffff),
            ]

            $0.test(name: "int32-to-uint8", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.IntegerOverflowError<UInt8>.int32(0x7fff_ffff),
                    in: "int32"))
            {
                try $0["int32"].decode(to: UInt8.self)
            }

            $0.test(name: "int32-to-int32", decoding: bson,
                expecting: 0x7fff_ffff)
            {
                try $0["int32"].decode(to: Int32.self)
            }

            $0.test(name: "int32-to-int", decoding: bson,
                expecting: 0x7fff_ffff)
            {
                try $0["int32"].decode(to: Int.self)
            }

            $0.test(name: "int64-to-int", decoding: bson,
                expecting: 0x7fff_ffff_ffff_ffff)
            {
                try $0["int64"].decode(to: Int.self)
            }
            $0.test(name: "uint64-to-int", decoding: bson,
                expecting: 0x7fff_ffff_ffff_ffff)
            {
                try $0["uint64"].decode(to: Int.self)
            }
        }

        tests.group("tuple")
        {
            let bson:BSON.Document<[UInt8]> =
            [
                "none":     [],
                "two":      ["a", "b"],
                "three":    ["a", "b", "c"],
                "four":     ["a", "b", "c", "d"],

                "heterogenous": ["a", "b", 0, "d"],
            ]

            $0.test(name: "none-to-two", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 0, expected: 2),
                    in: "none"))
            {
                try $0["none"].decode
                {
                    try $0.array(count: 2)
                }
            }

            $0.test(name: "two-to-two", decoding: bson,
                expecting: ["a", "b"])
            {
                try $0["two"].decode
                {
                    try $0.array(count: 2).elements
                }
            }

            $0.test(name: "three-to-two", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 3, expected: 2),
                    in: "three"))
            {
                try $0["three"].decode
                {
                    try $0.array(count: 2)
                }
            }

            $0.test(name: "three-by-two", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ArrayShapeError.init(invalid: 3, expected: nil),
                    in: "three"))
            {
                try $0["three"].decode
                {
                    try $0.array { $0.isMultiple(of: 2) }
                }
            }

            $0.test(name: "four-by-two", decoding: bson,
                expecting: ["a", "b", "c", "d"])
            {
                try $0["four"].decode
                {
                    (try $0.array { $0.isMultiple(of: 2) }).elements
                }
            }

            $0.test(name: "map", decoding: bson,
                expecting: ["a", "b", "c", "d"])
            {
                try $0["four"].decode(to: [String].self)
            }

            $0.test(name: "map-invalid", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.DecodingError<Int>.init(
                        BSON.TypecastError<BSON.UTF8<ArraySlice<UInt8>>>.init(invalid: .int64),
                        in: 2),
                    in: "heterogenous"))
            {
                try $0["heterogenous"].decode(to: [String].self)
            }

            $0.test(name: "element", decoding: bson, expecting: "c")
            {
                try $0["four"].decode
                {
                    try (try $0.array { 2 < $0 })[2].decode(to: String.self)
                }
            }

            $0.test(name: "element-invalid", decoding: bson,
                failure: BSON.DecodingError<String>.init(
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
        
        tests.group("document")
        {
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

            $0.test(name: "key-not-unique", decoding: degenerate,
                failure: BSON.DictionaryKeyError.duplicate("present"))
            {
                try $0["not-present"].decode(to: Bool.self)
            }

            $0.test(name: "key-not-present", decoding: bson,
                failure: BSON.DictionaryKeyError.undefined("not-present"))
            {
                try $0["not-present"].decode(to: Bool.self)
            }

            $0.test(name: "key-matching", decoding: bson,
                expecting: true)
            {
                try $0["inhabited"].decode(to: Bool.self)
            }

            $0.test(name: "key-not-matching", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.TypecastError<BSON.UTF8<ArraySlice<UInt8>>>.init(invalid: .bool),
                    in: "inhabited"))
            {
                try $0["inhabited"].decode(to: String.self)
            }

            $0.test(name: "key-not-matching-inhabited", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.TypecastError<Bool>.init(invalid: .null),
                    in: "present"))
            {
                try $0["present"].decode(to: Bool.self)
            }

            $0.test(name: "key-inhabited", decoding: bson,
                expecting: .some(true))
            {
                try $0["inhabited"].decode(to: Bool?.self)
            }

            $0.test(name: "key-null", decoding: bson,
                expecting: nil)
            {
                try $0["present"].decode(to: Bool?.self)
            }

            $0.test(name: "key-optional", decoding: bson,
                expecting: nil)
            {
                try $0["not-present"]?.decode(to: Bool.self)
            }

            $0.test(name: "key-optional-null", decoding: bson,
                expecting: .some(.none))
            {
                try $0["present"]?.decode(to: Bool?.self)
            }

            $0.test(name: "key-optional-inhabited", decoding: bson,
                expecting: .some(.some(true)))
            {
                try $0["inhabited"]?.decode(to: Bool?.self)
            }

            // should throw an error instead of returning [`nil`]().
            $0.test(name: "key-optional-not-inhabited", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.TypecastError<Bool>.init(invalid: .null),
                    in: "present"))
            {
                try $0["present"]?.decode(to: Bool.self)
            }
        }

        tests.group("binary")
        {
            let md5:BSON.Binary<[UInt8]> = .init(subtype: .md5,
                bytes: [0xff, 0xfe, 0xfd])
            let bson:BSON.Document<[UInt8]> =
            [
                "md5": .binary(md5),
            ]

            $0.test(name: "md5")
            {
                let dictionary:BSON.Dictionary<ArraySlice<UInt8>> = try .init(
                    fields: try bson.parse())
                let decoded:BSON.Binary<ArraySlice<UInt8>> = try dictionary["md5"].decode(
                    as: BSON.Binary<ArraySlice<UInt8>>.self)
                {
                    $0
                }
                $0.assert(md5 == decoded, name: "value")
            }
        }

        tests.group("losslessstringconvertible")
        {
            let bson:BSON.Document<[UInt8]> =
            [
                "string": "e\u{0301}e\u{0301}",
                "character": "e\u{0301}",
                "unicode-scalar": "e",
            ]

            $0.test(name: "unicode-scalar-from-string", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}e\u{0301}"),
                    in: "string"))
            {
                try $0["string"].decode(to: Unicode.Scalar.self)
            }
            $0.test(name: "unicode-scalar-from-character", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Unicode.Scalar>.init(invalid: "e\u{0301}"),
                    in: "character"))
            {
                try $0["character"].decode(to: Unicode.Scalar.self)
            }
            $0.test(name: "unicode-scalar", decoding: bson,
                expecting: "e")
            {
                try $0["unicode-scalar"].decode(to: Unicode.Scalar.self)
            }

            $0.test(name: "character-from-string", decoding: bson,
                failure: BSON.DecodingError<String>.init(
                    BSON.ValueError<String, Character>.init(invalid: "e\u{0301}e\u{0301}"),
                    in: "string"))
            {
                try $0["string"].decode(to: Character.self)
            }
            $0.test(name: "character", decoding: bson,
                expecting: "e\u{0301}")
            {
                try $0["character"].decode(to: Character.self)
            }
            
            $0.test(name: "string", decoding: bson,
                expecting: "e\u{0301}e\u{0301}")
            {
                try $0["string"].decode(to: String.self)
            }
        }
    }
}
