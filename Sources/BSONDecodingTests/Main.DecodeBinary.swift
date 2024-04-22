import BSONDecoding
import Testing_

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
            let md5:BSON.BinaryView<ArraySlice<UInt8>> = .init(subtype: .md5,
                bytes: [0xff, 0xfe, 0xfd])
            let bson:BSON.Document = ["md5": .binary(md5)]

            tests.do
            {
                let bson:BSON.DocumentDecoder<BSON.Key> = try .init(
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
