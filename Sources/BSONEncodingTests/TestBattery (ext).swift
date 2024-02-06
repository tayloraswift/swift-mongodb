import BSONEncoding
import Testing

extension TestBattery
{
    static
    func run(_ tests:TestGroup?,
        encoded:BSON.Document,
        literal:BSON.Document)
    {
        guard
        let tests:TestGroup
        else
        {
            return
        }

        tests.expect(encoded ==? literal)

        guard   let encoded:[(key:BSON.Key, value:BSON.AnyValue)] =
                    tests.do({ try encoded.parse { ($0, $1) } }),
                let literal:[(key:BSON.Key, value:BSON.AnyValue)] =
                    tests.do({ try literal.parse { ($0, $1) } })
        else
        {
            return
        }

        tests.expect(encoded.map(\.key)   ..? literal.map(\.key))
        tests.expect(encoded.map(\.value) ..? literal.map(\.value))
    }
}
