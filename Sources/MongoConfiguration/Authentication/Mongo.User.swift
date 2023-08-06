import MongoSchema

extension Mongo
{
    @frozen public
    struct User:Sendable
    {
        public
        let username:String
        public
        let password:String

        @inlinable public
        init(username:String, password:String)
        {
            self.username = username
            self.password = password
        }
    }
}
extension Mongo.User:MongoLoginMode
{
    @inlinable public
    func credentials(authentication:Mongo.Authentication?,
        database:Mongo.Database?) -> Mongo.Credentials?
    {
        .init(authentication: authentication,
            username: self.username,
            password: self.password,
            database: database ?? .admin)
    }
}
