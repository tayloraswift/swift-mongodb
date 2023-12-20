import MongoABI

extension Mongo
{
    @frozen public
    struct User:Sendable
    {
        @usableFromInline
        let authentication:Authentication?

        @inlinable public
        init(_ authentication:Authentication?)
        {
            self.authentication = authentication
        }
    }
}
extension Mongo.User:Mongo.LoginMode
{
    @inlinable public
    func credentials(
        userinfo:(username:String, password:String),
        database:Mongo.Database?) -> Mongo.Credentials?
    {
        .init(authentication: self.authentication,
            username: userinfo.username,
            password: userinfo.password,
            database: database ?? .admin)
    }
}
