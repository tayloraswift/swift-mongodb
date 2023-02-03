import BSONEncoding
import Testing

@main
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        do
        {
            let tests:TestGroup = tests / "literal-inference"

            TestEncoding(tests / "integer",
                encoded: .init
                {
                    $0["default"] = 1
                    $0["int32"] = 1 as Int32
                    $0["int64"] = 1 as Int64
                    $0["uint64"] = 1 as UInt64
                },
                literal:
                [
                    "default": 1,
                    "int32": .int32(1),
                    "int64": .int64(1),
                    "uint64": .uint64(1),
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
                    $0["c"] = "string" as BSON.UTF8<String.UTF8View>
                    $0["d"] = "string" as BSON.UTF8<String.UTF8View>
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
                    $0["c"] = [1, .null, 3] as BSON.Tuple<[UInt8]>
                    $0["d"] = [1, .null, 3] as BSON.Tuple<[UInt8]>
                },
                literal:
                [
                    "a": [1, .null, 3],
                    "b": .tuple([1, .null, 3]),
                    "c": [1, .null, 3],
                    "d": .tuple([1, .null, 3]),
                ])
            
            TestEncoding(tests / "tuple",
                encoded: .init
                {
                    $0["a"] = [1, 2, 3]
                    $0["b"] = [1, 2, 3]
                    $0["c"] = [1, 2, 3] as BSON.Tuple<[UInt8]>
                    $0["d"] = [1, 2, 3] as BSON.Tuple<[UInt8]>
                },
                literal:
                [
                    "a": [1, 2, 3],
                    "b": .tuple([1, 2, 3]),
                    "c": [1, 2, 3],
                    "d": .tuple([1, 2, 3]),
                ])
            
            TestEncoding(tests / "document",
                encoded: .init
                {
                    $0["a"] = .init
                    {
                        $0["a"] = 1
                        $0["b"] = 2
                        $0["c"] = 3
                    }
                    $0["b"] = .init
                    {
                        $0["a"] = 1
                        $0["b"] = 2
                        $0["c"] = 3
                    }
                    $0["c"] = ["a": 1, "b": 2, "c": 3] as BSON.Document<[UInt8]>
                    $0["d"] = ["a": 1, "b": 2, "c": 3] as BSON.Document<[UInt8]>
                },
                literal:
                [
                    "a": ["a": 1, "b": 2, "c": 3],
                    "b": .document(["a": 1, "b": 2, "c": 3]),
                    "c": ["a": 1, "b": 2, "c": 3],
                    "d": .document(["a": 1, "b": 2, "c": 3]),
                ])
        }
        do
        {
            let tests:TestGroup = tests / "type-inference"

            TestEncoding(tests / "binary",
                encoded: .init
                {
                    $0["a"] = BSON.Binary<[UInt8]>.init(subtype: .generic,
                        bytes: [0xff, 0xff, 0xff])
                },
                literal:
                [
                    "a": .binary(.init(subtype: .generic,
                        bytes: [0xff, 0xff, 0xff])),
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
        do
        {
            let tests:TestGroup = tests / "elided-collections"

            TestEncoding(tests / "string",
                encoded: .init
                {
                    $0["a", elide: true] = ""
                    $0["b", elide: true] = "foo"
                    $0["c", elide: false] = "foo"
                    $0["d", elide: false] = ""
                },
                literal:
                [
                    "b": "foo",
                    "c": "foo",
                    "d": "",
                ])
            
            TestEncoding(tests / "array",
                encoded: .init
                {
                    $0["a", elide: true] = []
                    $0["b", elide: true] = [1]
                    $0["c", elide: false] = [1]
                    $0["d", elide: false] = []
                },
                literal:
                [
                    "b": [1],
                    "c": [1],
                    "d": [],
                ])
            
            TestEncoding(tests / "document",
                encoded: .init
                {
                    $0["a", elide: true] = [:]
                    $0["b", elide: true] = .init
                    {
                        $0["x"] = 1
                    }
                    $0["c", elide: false] = .init
                    {
                        $0["x"] = 1
                    }
                    $0["d", elide: false] = [:]
                },
                literal:
                [
                    "b": ["x": 1],
                    "c": ["x": 1],
                    "d": [:],
                ])
        }
        do
        {
            let _:BSON.Fields = [:]
            let tests:TestGroup = tests / "elided-fields"

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
        do
        {
            let tests:TestGroup = tests / "duplicate-fields"

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
