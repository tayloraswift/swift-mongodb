import BSONEncoding
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        if  let tests:TestGroup = tests / "literal-inference"
        {

            TestEncoding(tests / "integer",
                encoded: .init
                {
                    $0["default"] = 1
                    $0["default-long"] = 0x7fff_ffff_ffff_ffff
                    $0["int32"] = 1 as Int32
                    $0["int64"] = 1 as Int64
                    $0["int"] = 1 as Int
                    $0["int-long"] = 0x7fff_ffff_ffff_ffff as Int
                },
                literal:
                [
                    "default": 1,
                    "default-long": 0x7fff_ffff_ffff_ffff,
                    "int32": .int32(1),
                    "int64": .int64(1),
                    "int": .int32(1),
                    "int-long": .int64(0x7fff_ffff_ffff_ffff),
                ])

            TestEncoding(tests / "floating-point",
                encoded: .init
                {
                    $0["default"] = 1.0
                    $0["a"] = 1.0 as Double
                },
                literal:
                [
                    "default": 1.0,
                    "a": .double(1.0),
                ])

            TestEncoding(tests / "string",
                encoded: .init
                {
                    $0["a"] = "string"
                    $0["b"] = "string"
                    $0["c"] = "string" as BSON.UTF8View<String.UTF8View>
                    $0["d"] = "string" as BSON.UTF8View<String.UTF8View>
                },
                literal:
                [
                    "a": "string",
                    "b": "string",
                    "c": .string(.init(from: "string")),
                    "d": .string(.init(from: "string")),
                ])

            TestEncoding(tests / "optionals",
                encoded: .init
                {
                    $0["a"] = [1, nil, 3]
                    $0["b"] = [1, nil, 3]
                    $0["c"] = [1, .null, 3] as BSON.ListView<[UInt8]>
                    $0["d"] = [1, .null, 3] as BSON.ListView<[UInt8]>
                },
                literal:
                [
                    "a": [1, .null, 3],
                    "b": .list([1, .null, 3]),
                    "c": [1, .null, 3],
                    "d": .list([1, .null, 3]),
                ])

            TestEncoding(tests / "list",
                encoded: .init
                {
                    $0["a"] = [1, 2, 3]
                    $0["b"] = [1, 2, 3]
                    $0["c"] = [1, 2, 3] as BSON.ListView<[UInt8]>
                    $0["d"] = [1, 2, 3] as BSON.ListView<[UInt8]>
                },
                literal:
                [
                    "a": [1, 2, 3],
                    "b": .list([1, 2, 3]),
                    "c": [1, 2, 3],
                    "d": .list([1, 2, 3]),
                ])

            TestEncoding(tests / "document",
                encoded: .init
                {
                    $0["a"]
                    {
                        $0["a"] = 1
                        $0["b"] = 2
                        $0["c"] = 3
                    }
                    $0["b"]
                    {
                        $0["a"] = 1
                        $0["b"] = 2
                        $0["c"] = 3
                    }
                    $0["c"] = ["a": 1, "b": 2, "c": 3] as BSON.DocumentView<[UInt8]>
                    $0["d"] = ["a": 1, "b": 2, "c": 3] as BSON.DocumentView<[UInt8]>
                },
                literal:
                [
                    "a": ["a": 1, "b": 2, "c": 3],
                    "b": .document(["a": 1, "b": 2, "c": 3]),
                    "c": ["a": 1, "b": 2, "c": 3],
                    "d": .document(["a": 1, "b": 2, "c": 3]),
                ])
        }
        if  let tests:TestGroup = tests / "type-inference"
        {

            TestEncoding(tests / "binary",
                encoded: .init
                {
                    $0["a"] = BSON.BinaryView<[UInt8]>.init(subtype: .generic,
                        slice: [0xff, 0xff, 0xff])
                },
                literal:
                [
                    "a": .binary(.init(subtype: .generic,
                        slice: [0xff, 0xff, 0xff])),
                ])

            TestEncoding(tests / "max",
                encoded: .init
                {
                    $0["max"] = BSON.Max.init()
                },
                literal:
                [
                    "max": .max,
                ])

            TestEncoding(tests / "min",
                encoded: .init
                {
                    $0["min"] = BSON.Min.init()
                },
                literal:
                [
                    "min": .min,
                ])

            TestEncoding(tests / "null",
                encoded: .init
                {
                    $0["null"] = (nil as Never?) as Never??
                },
                literal:
                [
                    "null": .null,
                ])
        }
        if  let tests:TestGroup = tests / "string"
        {
            TestEncoding(tests,
                encoded: .init
                {
                    $0["a"] = ""
                    $0["b"] = "foo"
                    $0["c"] = "foo\u{0}"
                },
                literal:
                [
                    "a": "",
                    "b": "foo",
                    "c": "foo\u{0}",
                ])
        }
        if  let tests:TestGroup = tests / "array"
        {
            TestEncoding(tests,
                encoded: .init
                {
                    $0["a"] = [] as [Never]
                    $0["b"] = [1]
                    $0["c"]
                    {
                        $0.append(1)
                        $0.append("x")
                        $0.append(5.5)
                    }
                },
                literal:
                [
                    "a": [],
                    "b": [1],
                    "c": [1, "x", 5.5],
                ])
        }
        if  let tests:TestGroup = tests / "document"
        {
            TestEncoding(tests,
                encoded: .init
                {
                    $0["a"] = [:]
                    $0["b"]
                    {
                        $0["x"] = 1
                    }
                    $0["c"]
                    {
                        $0["x"] = 1
                        $0["y"] = 2
                    }
                },
                literal:
                [
                    "a": [:],
                    "b": ["x": 1],
                    "c": ["x": 1, "y": 2],
                ])
        }
        if  let tests:TestGroup = tests / "elided-fields"
        {
            let _:BSON.Document = [:]

            TestEncoding(tests / "null",
                encoded: .init
                {
                    $0["elided"] = nil as Never??
                    $0["inhabited"] = (nil as Never?) as Never??
                },
                literal:
                [
                    "inhabited": .null,
                ])

            TestEncoding(tests / "integer",
                encoded: .init
                {
                    $0["elided"] = nil as Int?
                    $0["inhabited"] = 5
                },
                literal:
                [
                    "inhabited": 5,
                ])

            TestEncoding(tests / "optional",
                encoded: .init
                {
                    $0["elided"] = nil as Int??
                    $0["inhabited"] = (5 as Int?) as Int??
                    $0["uninhabited"] = (nil as Int?) as Int??
                },
                literal:
                [
                    "inhabited": 5,
                    "uninhabited": .null,
                ])
        }
        if  let tests:TestGroup = tests / "duplicate-fields"
        {

            TestEncoding(tests / "integer",
                encoded: .init
                {
                    $0["inhabited"] = 5
                    $0["uninhabited"] = nil as Never??
                    $0["inhabited"] = 7
                    $0["uninhabited"] = nil as Never??
                },
                literal:
                [
                    "inhabited": 5,
                    "inhabited": 7,
                ])
        }
    }
}
