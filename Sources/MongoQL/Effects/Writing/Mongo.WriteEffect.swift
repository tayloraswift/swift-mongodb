import BSON

extension Mongo
{
    public
    protocol WriteEffect
    {
        associatedtype DeletePlurality:BSONEncodable
        associatedtype UpdatePlurality:BSONEncodable
        associatedtype ExecutionPolicy
    }
}
