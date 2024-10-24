import MongoDB

extension Mongo
{
    struct SingleConfiguration:TestConfiguration
    {
        typealias Login = User

        let userinfo:(username:String, password:String)
        let members:Seedlist
        let servers:[ReadPreference]

        func configure(options:inout DriverOptions<Authentication>)
        {
            options.connectionTimeout = .milliseconds(1000)
            options.authentication = .sasl(.sha256)
        }
    }
}
