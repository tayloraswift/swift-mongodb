extension Mongo
{
    @frozen public
    struct Guest:Sendable
    {
        @inlinable public
        init(_:Never?)
        {
        }
    }
}
extension Mongo.Guest:Mongo.LoginMode
{
    /// Always returns nil.
    @inlinable public
    func credentials(userinfo _:Void, database _:Never?) -> Mongo.Credentials?
    {
        nil
    }
}
