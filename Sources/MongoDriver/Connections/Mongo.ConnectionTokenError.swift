extension Mongo
{
    public
    struct ConnectionTokenError:Equatable, Error
    {
        public
        let recorded:ConnectionToken
        public
        let invalid:ConnectionToken

        init(recorded:ConnectionToken, invalid:ConnectionToken)
        {
            self.recorded = recorded
            self.invalid = invalid
        }
    }
}
extension Mongo.ConnectionTokenError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid connection token '\(self.invalid)' (recorded token: \(self.recorded))"
    }
}
