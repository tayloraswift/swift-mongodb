import Testing
import BSONDecoding

func TestDecoding<Failure, Unexpected>(_ tests:TestGroup, bson:BSON.DocumentView<[UInt8]>, 
    catching error:Failure,
    with decode:(BSON.DocumentDecoder<String, ArraySlice<UInt8>>) throws -> Unexpected)
    where Failure:Equatable & Error
{
    tests.do(catching: error)
    {
        _ = try decode(try bson.decoder())
    }
}
func TestDecoding<Decoded>(_ tests:TestGroup, bson:BSON.DocumentView<[UInt8]>,
    to expected:Decoded,
    with decode:(BSON.DocumentDecoder<String, ArraySlice<UInt8>>) throws -> Decoded)
    where Decoded:Equatable
{
    tests.do
    {
        let decoded:Decoded = try decode(try bson.decoder())
        tests.expect(expected ==? decoded)
    }
}
