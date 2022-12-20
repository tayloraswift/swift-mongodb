import BSONSchema
import BSONUnions

extension Mongo.WriteConcern
{
    @frozen public
    enum Level:Hashable, Sendable
    {
        case majority
        case custom(String)
        case count(Int)
    }
}
extension Mongo.WriteConcern.Level:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .majority:
            "majority".encode(to: &field)
        case .custom(let concern):
            concern.encode(to: &field)
        case .count(let instances):
            instances.encode(to: &field)
        }
    }
}
extension Mongo.WriteConcern.Level:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        if case .string(let string) = bson
        {
            let string:String = string.description
            self = string == "majority" ? .majority : .custom(string)
        }
        else if let count:Int = try bson.as(Int.self)
        {
            self = .count(count)
        }
        else
        {
            throw BSON.TypecastError<Self>.init(invalid: bson.type)
        }
    }
}