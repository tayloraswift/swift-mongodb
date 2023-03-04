extension Mongo
{
    public
    struct SessionsUnsupportedError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension Mongo.SessionsUnsupportedError:CustomStringConvertible
{
    public
    var description:String
    {
        "Timed out waiting for topology to indicate it supports logical sessions."
    }
}
