import BSONDecoding
import Testing

extension Main
{
    enum DecodeBinary
    {
    }
}
extension Main.DecodeBinary:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        if  let tests:TestGroup = tests / "md5"
        {
            let md5:BSON.BinaryView<[UInt8]> = .init(subtype: .md5,
                slice: [0xff, 0xfe, 0xfd])
            let bson:BSON.DocumentView<[UInt8]> =
            [
                "md5": .binary(md5),
            ]

            tests.do
            {
                let bson:BSON.DocumentDecoder<BSON.Key, [UInt8]> = try .init(
                    parsing: bson)
                let decoded:BSON.BinaryView<ArraySlice<UInt8>> = try bson["md5"].decode(
                    as: BSON.BinaryView<ArraySlice<UInt8>>.self)
                {
                    $0
                }
                tests.expect(true: md5 == decoded)
            }
        }
    }
}
