extension Mongo
{
    @frozen public
    struct Guest:Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
extension Mongo.Guest:MongoLoginMode
{
    @inlinable public
    func credentials(authentication _:Never?, database _:Never?) -> Mongo.Credentials?
    {
        nil
    }
}
