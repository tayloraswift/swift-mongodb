import BSONEncoding

extension Mongo
{
    /// The MongoDB `configureFailPoint` command.
    @frozen public
    enum ConfigureFailpoint<Options>:Sendable where Options:MongoFailpoint
    {
        case always(Options)
        case random(Options, probability:Double)
        case times(Options, count:Int)
        case off
    }
}
extension Mongo.ConfigureFailpoint
{
    @inlinable public static
    func once(_ options:Options) -> Self
    {
        .times(options, count: 1)
    }
}
extension Mongo.ConfigureFailpoint:MongoImplicitSessionCommand, MongoCommand
{
    /// The string [`"configureFailPoint"`](). Note that the capitalization
    /// is different from that of the command type.
    @inlinable public static
    var type:Mongo.CommandType { .configureFailpoint }

    /// `ConfigureFailpoint` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Document
    {
        Self.type(Options.name)
        {
            switch self
            {
            case .always(let options):
                $0["data"] = options
                $0["mode"] = "alwaysOn"
            
            case .random(let options, probability: let probability):
                $0["data"] = options
                $0["mode"]
                {
                    $0["activationProbability"] = probability
                }
            
            case .times(let options, count: let count):
                $0["data"] = options
                $0["mode"]
                {
                    $0["times"] = count
                }
            
            case .off:
                $0["mode"] = "off"
            }
        }
    }
}
