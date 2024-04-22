import BSONDecoding
import Testing_

extension TestBattery
{
    static
    func run<Failure, Unexpected>(_ tests:TestGroup?,
        bson:BSON.Document,
        catching error:Failure,
        with decode:(BSON.DocumentDecoder<BSON.Key>) throws -> Unexpected)
        where Failure:Equatable & Error
    {
        tests?.do(catching: error)
        {
            _ = try decode(try .init(parsing: bson))
        }
    }
    static
    func run<Decoded>(_ tests:TestGroup?,
        bson:BSON.Document,
        to expected:Decoded,
        with decode:(BSON.DocumentDecoder<BSON.Key>) throws -> Decoded)
        where Decoded:Equatable
    {
        if  let tests:TestGroup
        {
            tests.do
            {
                let decoded:Decoded = try decode(try .init(parsing: bson))
                tests.expect(expected ==? decoded)
            }
        }
    }
}
