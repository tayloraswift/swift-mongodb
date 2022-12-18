import Base16
import BSON
import BSONUnions
import Testing

struct InvalidBSONTest
{
    let name:String
    let invalid:String

    init(name:String, invalid:String)
    {
        self.name = name
        self.invalid = invalid
    }
}
extension InvalidBSONTest:SyncTestCase
{
    func run(tests _:inout Tests) throws
    {
        let invalid:[UInt8] = Base16.decode(self.invalid.utf8)

        var input:BSON.Input<[UInt8]> = .init(invalid)
        let document:BSON.Document<ArraySlice<UInt8>> = try input.parse(
            as: BSON.Document<ArraySlice<UInt8>>.self)
        try input.finish()
        _ = try document.canonicalized()
    }
}
