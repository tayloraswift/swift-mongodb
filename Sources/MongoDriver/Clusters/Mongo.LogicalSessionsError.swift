import MongoTopology

extension Mongo
{
    public
    struct LogicalSessionsError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension Mongo.LogicalSessionsError:CustomStringConvertible
{
    public
    var description:String
    {
        "Timed out waiting for topology to indicate it supports logical sessions."
    }
}
