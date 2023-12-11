import MongoDB
import MongoTesting

enum SingleConfiguration:MongoTestConfiguration
{
    typealias Login = Mongo.User

    static
    let userinfo:(username:String, password:String) = ("root", "80085")

    static
    let members:Mongo.Seedlist = ["mongo-single": 27017]

    static
    func configure(options:inout Mongo.DriverOptions<Mongo.Authentication>)
    {
        options.connectionTimeout = .milliseconds(1000)
        options.authentication = .sasl(.sha256)
    }
}
extension SingleConfiguration:CursorTestConfiguration
{
    static
    let servers:[Mongo.ReadPreference] = [.primary]
}
