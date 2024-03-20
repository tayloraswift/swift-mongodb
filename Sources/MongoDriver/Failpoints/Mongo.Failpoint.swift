import BSON

extension Mongo
{
    public
    protocol Failpoint:BSONEncodable, Sendable
    {
        static
        var name:String { get }
    }
}
