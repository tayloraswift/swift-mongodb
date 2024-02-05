import BSONDecoding
import Testing

extension Main
{
    enum DecodeVoid
    {
    }
}
extension Main.DecodeVoid:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let bson:BSON.DocumentView =
        [
            "null": .null,
            "max": .max,
            "min": .min,
        ]

        (tests / "null")?.do
        {
            let bson:BSON.DocumentDecoder<BSON.Key> = try .init(
                parsing: bson)
            let _:BSON.Null = try bson["null"].decode(to: BSON.Null.self)
        }
        Self.run(tests / "max", bson: bson, to: .init())
        {
            try $0["max"].decode(to: BSON.Max.self)
        }
        Self.run(tests / "min", bson: bson, to: .init())
        {
            try $0["min"].decode(to: BSON.Min.self)
        }
    }
}
