import BSONDecoding
import Testing

@Suite
enum DecodeBinary
{
    @Test
    static func MD5() throws
    {
        let md5:BSON.BinaryView<ArraySlice<UInt8>> = .init(subtype: .md5,
            bytes: [0xff, 0xfe, 0xfd])
        let document:BSON.Document = ["md5": .binary(md5)]

        let decoder:BSON.DocumentDecoder<BSON.Key> = try .init(parsing: document)
        let decoded:BSON.BinaryView<ArraySlice<UInt8>> = try decoder["md5"].decode()

        #expect(md5 == decoded)
    }
}
