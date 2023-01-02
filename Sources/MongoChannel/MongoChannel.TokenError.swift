extension MongoChannel
{
    public
    struct TokenError:Equatable, Error
    {
        public
        let recorded:Token
        public
        let invalid:Token

        public
        init(recorded:Token, invalid:Token)
        {
            self.recorded = recorded
            self.invalid = invalid
        }
    }
}
extension MongoChannel.TokenError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid connection token '\(self.invalid)' (recorded token: \(self.recorded))"
    }
}
