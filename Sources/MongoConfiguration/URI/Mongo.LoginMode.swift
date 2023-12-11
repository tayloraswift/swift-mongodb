extension Mongo
{
    public
    typealias LoginMode = _MongoLoginMode
}

public
protocol _MongoLoginMode<Authentication>
{
    associatedtype Authentication
    associatedtype Userinfo:Sendable
    associatedtype Database

    init(_ authentication:Authentication?)

    func credentials(userinfo:Userinfo, database:Database?) -> Mongo.Credentials?
}
