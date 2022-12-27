extension Mongo
{
    public
    struct SessionMediumTimeoutError:Error
    {
        let selector:SessionMediumSelector

        init(selector:SessionMediumSelector)
        {
            self.selector = selector
        }
    }
}
extension Mongo.SessionMediumTimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        "timed out waiting for session medium matching selector '\(self.selector)'"
    }
}
