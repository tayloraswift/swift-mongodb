import MongoABI

extension Mongo.URI
{
    /// The first three significant components of a connection string URI.
    /// It contains login credentials (which may be empty), a list of
    /// domains, and a path component.
    ///
    /// This type is less generic than ``Base`` or ``Authority``, because
    /// you can only use it with explicit login credentials.
    @frozen public
    struct Location:Sendable
    {
        public
        let userinfo:(username:String, password:String)
        public
        let domains:Mongo.SeedingMethod
        public
        let path:Mongo.Database

        @inlinable public
        init(userinfo:(username:String, password:String),
            domains:Mongo.SeedingMethod,
            path:Mongo.Database)
        {
            self.userinfo = userinfo
            self.domains = domains
            self.path = path
        }
    }
}
extension Mongo.URI.Location:Mongo.ServiceLocator
{
    public
    typealias Login = Mongo.User

    @inlinable public
    var database:Mongo.Database? { self.path }
}
