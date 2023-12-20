import MongoDB
import MongoTesting

enum ReplicatedConfigurationWithLongerTimeout:MongoTestConfiguration
{
    typealias Login = Mongo.Guest

    static
    let members:Mongo.Seedlist = ReplicatedConfiguration.members

    static
    func configure(options:inout Mongo.DriverOptions<Never>)
    {
        options.connectionTimeout = .milliseconds(2000)
    }
}
