import BSONEncoding
import BSONView
import Testing

func TestEncoding(_ tests:TestGroup,
    encoded:BSON.Document,
    literal:BSON.DocumentView<[UInt8]>)
{
    let encoded:BSON.DocumentView<[UInt8]> = .init(encoded)

    tests.expect(encoded ==? literal)

    guard   let encoded:[(key:BSON.Key, value:BSON.AnyValue<ArraySlice<UInt8>>)] =
                tests.do({ try encoded.parse { ($0, $1) } }),
            let literal:[(key:BSON.Key, value:BSON.AnyValue<ArraySlice<UInt8>>)] =
                tests.do({ try literal.parse { ($0, $1) } })
    else
    {
        return
    }

    tests.expect(encoded.map(\.key)   ..? literal.map(\.key))
    tests.expect(encoded.map(\.value) ..? literal.map(\.value))
}
