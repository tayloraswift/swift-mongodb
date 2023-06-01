import MongoDB

@rethrows public
protocol MongoTestBattery
{
    var id:String { get }
    var logging:Mongo.LoggingLevel? { get }

    func run(_ tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
}
extension MongoTestBattery
{
    @inlinable public
    var id:String { "\(Self.self)" }

    @inlinable public
    var logging:Mongo.LoggingLevel? { nil }
}
