import BSONDecoding
import BSONEncoding
import BSON

extension Mongo.WriteConcern
{
    public
    enum Acknowledgement:Hashable, Sendable
    {
        case mode(String)
        case votes(Int)
    }
}
extension Mongo.WriteConcern.Acknowledgement
{
    /// Same as ``votes(_:)``, but traps if the argument is zero or negative.
    static
    func acknowledged(by votes:Int) -> Self
    {
        if 0 < votes
        {
            return .votes(votes)
        }
        else
        {
            fatalError("Cannot use acknowledged(by:) to specify unacknowledged write concern.")
        }
    }
}
extension Mongo.WriteConcern.Acknowledgement:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .mode(let mode):
            mode.encode(to: &field)
        
        case .votes(let votes):
            votes.encode(to: &field)
        }
    }
}
extension Mongo.WriteConcern.Acknowledgement:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        if case .string(let string) = bson
        {
            self = .mode(string.description)
        }
        else if let votes:Int = try bson.as(Int.self)
        {
            self = .votes(votes)
        }
        else
        {
            throw BSON.TypecastError<Self>.init(invalid: bson.type)
        }
    }
}
