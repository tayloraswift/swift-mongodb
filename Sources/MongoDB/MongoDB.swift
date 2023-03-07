@inlinable public
var MongoDB:Mongo.URI.Base<Mongo.Guest, Mongo.DirectSeeding>
{
    .init(userinfo: .init())
}

@inlinable public
func MongoDB(_ username:String,
    _ password:String) -> Mongo.URI.Base<Mongo.User, Mongo.DirectSeeding>
{
    .init(userinfo: .init(username: username, password: password))
}
