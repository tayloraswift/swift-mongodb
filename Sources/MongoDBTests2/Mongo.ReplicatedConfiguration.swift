import MongoDB
import MongoTesting
import UnixTime

extension Mongo
{
    struct ReplicatedConfiguration:TestConfiguration
    {
        typealias Login = Guest

        let connectionTimeout:Milliseconds
        let members:Mongo.Seedlist
        let servers:[Mongo.ReadPreference]

        func configure(options:inout DriverOptions<Never>)
        {
            options.connectionTimeout = self.connectionTimeout
        }
    }
}
