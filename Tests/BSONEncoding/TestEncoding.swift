import BSONEncoding
import BSONUnions
import Testing

func TestEncoding(_ tests:TestGroup,
    encoded:BSON.Fields,
    literal:BSON.Document<[UInt8]>)
{
    let encoded:BSON.Document<[UInt8]> = .init(encoded)

    tests.expect(encoded ==? literal)

    guard   let encoded:[(key:String, value:AnyBSON<ArraySlice<UInt8>>)] =
                tests.do({ try encoded.parse() }),
            let literal:[(key:String, value:AnyBSON<ArraySlice<UInt8>>)] =
                tests.do({ try literal.parse() })
    else
    {
        return
    }

    tests.expect(encoded.map(\.key)   ..? literal.map(\.key))
    tests.expect(encoded.map(\.value) ..? literal.map(\.value))
}
