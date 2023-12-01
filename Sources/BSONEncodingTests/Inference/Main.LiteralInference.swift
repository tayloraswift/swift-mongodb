import BSONEncoding
import Testing

extension Main
{
    enum LiteralInference
    {
    }
}
extension Main.LiteralInference:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests / "integer",
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

        Self.run(tests / "floating-point",
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

        Self.run(tests / "string",
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

        Self.run(tests / "optionals",
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

        Self.run(tests / "list",
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

        Self.run(tests / "document",
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
}
