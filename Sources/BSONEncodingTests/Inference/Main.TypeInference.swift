import BSONEncoding
import Testing

extension Main
{
    enum TypeInference
    {
    }
}
extension Main.TypeInference:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        Self.run(tests / "binary",
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

        Self.run(tests / "max",
            encoded: .init
            {
                $0["max"] = BSON.Max.init()
            },
            literal:
            [
                "max": .max,
            ])

        Self.run(tests / "min",
            encoded: .init
            {
                $0["min"] = BSON.Min.init()
            },
            literal:
            [
                "min": .min,
            ])

        Self.run(tests / "null",
            encoded: .init
            {
                $0["null"] = (nil as Never?) as Never??
            },
            literal:
            [
                "null": .null,
            ])
    }
}