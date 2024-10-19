import BSONDecoding
import Testing

@Suite
struct DecodeVoid
{
    private
    let bson:BSON.DocumentDecoder<BSON.Key>

    init() throws
    {
        let bson:BSON.Document =
        [
            "null": .null,
            "max": .max,
            "min": .min,
        ]

        self.bson = try .init(parsing: bson)
    }
}
extension DecodeVoid
{
    @Test
    func Null() throws
    {
        #expect(try BSON.Null.init() == self.bson["null"].decode())
    }

    @Test
    func Max() throws
    {
        #expect(try BSON.Max.init() == self.bson["max"].decode())
    }

    @Test
    func Min() throws
    {
        #expect(try BSON.Min.init() == self.bson["min"].decode())
    }
}

