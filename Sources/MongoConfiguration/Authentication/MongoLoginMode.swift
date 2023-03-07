public
protocol MongoLoginMode<Authentication>
{
    associatedtype Authentication
    associatedtype Database

    func credentials(authentication:Authentication?, database:Database?) -> Mongo.Credentials?
}
