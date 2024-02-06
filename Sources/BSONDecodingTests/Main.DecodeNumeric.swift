import BSONDecoding
import Testing

extension Main
{
    enum DecodeNumeric
    {
    }
}
extension Main.DecodeNumeric:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let bson:BSON.Document =
        [
            "int32": .int32(0x7fff_ffff),
            "int64": .int64(0x7fff_ffff_ffff_ffff),
            "uint64": .uint64(0x7fff_ffff_ffff_ffff),
        ]

        Self.run(tests / "int32-to-uint8", bson: bson,
            catching: BSON.DecodingError<BSON.Key>.init(
                BSON.IntegerOverflowError<UInt8>.int32(0x7fff_ffff),
                in: "int32"))
        {
            try $0["int32"].decode(to: UInt8.self)
        }

        Self.run(tests / "int32-to-int32", bson: bson,
            to: 0x7fff_ffff)
        {
            try $0["int32"].decode(to: Int32.self)
        }

        Self.run(tests / "int32-to-int", bson: bson,
            to: 0x7fff_ffff)
        {
            try $0["int32"].decode(to: Int.self)
        }

        Self.run(tests / "int64-to-int", bson: bson,
            to: 0x7fff_ffff_ffff_ffff)
        {
            try $0["int64"].decode(to: Int.self)
        }
        Self.run(tests / "uint64-to-int", bson: bson,
            to: 0x7fff_ffff_ffff_ffff)
        {
            try $0["uint64"].decode(to: Int.self)
        }
    }
}
