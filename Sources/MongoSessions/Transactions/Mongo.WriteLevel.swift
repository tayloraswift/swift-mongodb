import BSONSchema
import BSONUnions

extension Mongo
{
    @frozen public
    enum WriteLevel:Hashable, Sendable
    {
        case majority
        case custom(mode:String)
        case acknowledged(by:Int)
    }
}
extension Mongo.WriteLevel
{
    public static
    let unacknowledged:Self = .acknowledged(by: 0)
}
extension Mongo.WriteLevel:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .majority:
            "majority".encode(to: &field)
        
        case .custom(mode: let mode):
            mode.encode(to: &field)
        
        case .acknowledged(by: let count):
            count.encode(to: &field)
        }
    }
}
extension Mongo.WriteLevel:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        if case .string(let string) = bson
        {
            let string:String = string.description
            self = string == "majority" ? .majority : .custom(mode: string)
        }
        else if let count:Int = try bson.as(Int.self)
        {
            self = .acknowledged(by: count)
        }
        else
        {
            throw BSON.TypecastError<Self>.init(invalid: bson.type)
        }
    }
}
