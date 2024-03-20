extension Mongo
{
    public
    protocol LoginMode<Authentication>
    {
        associatedtype Authentication
        associatedtype Userinfo:Sendable
        associatedtype Database

        init(_ authentication:Authentication?)

        func credentials(userinfo:Userinfo, database:Database?) -> Credentials?
    }
}
