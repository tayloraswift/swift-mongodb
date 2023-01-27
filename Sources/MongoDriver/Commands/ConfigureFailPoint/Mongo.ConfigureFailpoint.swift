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
extension Mongo.ConfigureFailpoint:MongoCommand
{
    /// `ConfigureFailpoint` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    /// The string [`"configureFailPoint"`](). Note that the capitalization
    /// is different from that of the command type.
    @inlinable public static
    var name:String
    {
        "configureFailPoint"
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        //  note: capitalization
        bson[Self.name] = Options.name

        switch self
        {
        case .always(let options):
            bson["data"] = options
            bson["mode"] = "alwaysOn"
        
        case .random(let options, probability: let probability):
            bson["data"] = options
            bson["mode"] = .init
            {
                $0["activationProbability"] = probability
            }
        
        case .times(let options, count: let count):
            bson["data"] = options
            bson["mode"] = .init
            {
                $0["times"] = count
            }
        
        case .off:
            bson["mode"] = "off"
        }
    }
}
