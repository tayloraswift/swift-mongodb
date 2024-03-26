import BSON

extension Mongo
{
    @available(*, deprecated, renamed: "BSON.Timestamp")
    public
    typealias Timestamp = BSON.Timestamp
}
extension BSON.Timestamp:Mongo.Instant
{
}
