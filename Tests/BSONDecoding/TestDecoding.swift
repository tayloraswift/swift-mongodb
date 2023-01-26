import Testing
import BSONDecoding

func TestDecoding<Failure, Unexpected>(_ tests:TestGroup, bson:BSON.Document<[UInt8]>, 
    catching error:Failure,
    with decode:(BSON.Dictionary<ArraySlice<UInt8>>) throws -> Unexpected)
    where Failure:Equatable & Error
{
    tests.do(catching: error)
    {
        _ = try decode(try .init(fields: try bson.parse()))
    }
}
func TestDecoding<Decoded>(_ tests:TestGroup, bson:BSON.Document<[UInt8]>,
    to expected:Decoded,
    with decode:(BSON.Dictionary<ArraySlice<UInt8>>) throws -> Decoded)
    where Decoded:Equatable
{
    tests.do
    {
        let decoded:Decoded = try decode(try .init(fields: try bson.parse()))
        tests.expect(expected ==? decoded)
    }
}
