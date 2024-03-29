import BSON

extension Mongo
{
    @frozen public
    enum UpdatePhase:Equatable, Hashable, Sendable
    {
        case old
        case new
    }
}
extension Mongo.UpdatePhase:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        (self == .new).encode(to: &field)
    }
}
extension Mongo.UpdatePhase:Mongo.ModificationPhase
{
    @inlinable public static
    var field:BSON.Key { "new" }
}
