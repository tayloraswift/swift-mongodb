import Base16
import BSON
import BSONUnions
import Testing

func TestInvalidBSON(_ tests:TestGroup, invalid:String, catching error:some Error & Equatable)
{
    let invalid:[UInt8] = Base16.decode(invalid.utf8)

    var input:BSON.Input<[UInt8]> = .init(invalid)

    tests.do(catching: error)
    {
        let document:BSON.Document<ArraySlice<UInt8>> = try input.parse(
            as: BSON.Document<ArraySlice<UInt8>>.self)
        try input.finish()
        _ = try document.canonicalized()
    }
}
