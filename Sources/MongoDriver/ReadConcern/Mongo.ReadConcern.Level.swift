import BSONEncoding

extension Mongo.ReadConcern
{
    @frozen public
    enum Level:Sendable, Equatable
    {
        case ratification(Mongo.ReadConcern)
        case snapshot
    }
}
extension Mongo.ReadConcern.Level:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .snapshot:
            return "snapshot"
        case .ratification(let level):
            return level.rawValue
        }
    }
}
extension Mongo.ReadConcern.Level:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.description.encode(to: &field)
    }
}
