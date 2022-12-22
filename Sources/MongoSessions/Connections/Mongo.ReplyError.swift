import BSON

extension Mongo
{
    public
    enum ReplyError:Equatable, Error
    {
        case invalidStatusType(BSON)
    }
}
extension Mongo.ReplyError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .invalidStatusType(let variant):
            return "server returned status code of type '\(variant)'"
        }
    }
}
