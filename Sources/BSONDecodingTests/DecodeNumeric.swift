import BSONDecoding
import Testing

@Suite
struct DecodeNumeric
{
    private
    let bson:BSON.DocumentDecoder<BSON.Key>

    init() throws
    {
        let bson:BSON.Document =
        [
            "int32": .int32(0x7fff_ffff),
            "int64": .int64(0x7fff_ffff_ffff_ffff),
            "uint64": .timestamp(0x7fff_ffff_ffff_ffff),
        ]

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeNumeric
{
    @Test
    func Int32ToUInt8() throws
    {
        #expect(throws: BSON.DecodingError<BSON.Key>.init(
            BSON.IntegerOverflowError<UInt8>.int32(0x7fff_ffff),
            in: "int32"))
        {
            try self.bson["int32"].decode(to: UInt8.self)
        }
    }

    @Test
    func Int32ToInt32() throws
    {
        #expect(try 0x7fff_ffff == self.bson["int32"].decode(to: Int32.self))
    }

    @Test
    func Int32ToInt() throws
    {
        #expect(try 0x7fff_ffff == self.bson["int32"].decode(to: Int.self))
    }

    @Test
    func Int64ToInt() throws
    {
        #expect(try 0x7fff_ffff_ffff_ffff == self.bson["int64"].decode(to: Int.self))
    }
    @Test
    func UInt64ToInt() throws
    {
        #expect(try 0x7fff_ffff_ffff_ffff == self.bson["uint64"].decode(to: Int.self))
    }
}
