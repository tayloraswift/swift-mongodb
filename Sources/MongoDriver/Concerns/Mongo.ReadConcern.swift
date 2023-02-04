import BSONEncoding

extension Mongo
{
    public
    struct ReadConcern:Sendable
    {
        let ordering:Ordering?
        let level:Level?

        private
        init(ordering:Ordering?, level:Level?)
        {
            self.ordering = ordering
            self.level = level
        }
    }
}
extension Mongo.ReadConcern
{
    static
    func level(_ level:Level?, after clusterTime:Mongo.Instant?) -> Self
    {
        .init(ordering: clusterTime.map(Ordering.after(_:)), level: level)
    }
    static
    func level(_ level:Level?, at clusterTime:Mongo.Instant?) -> Self
    {
        .init(ordering: clusterTime.map(Ordering.at(_:)), level: level)
    }
}
extension Mongo.ReadConcern
{
    public static
    func level(_ level:Mongo.ReadLevel?, after clusterTime:Mongo.Instant?) -> Self
    {
        .level(level.map(Level.init(_:)), after: clusterTime)
    }
    public static
    func snapshot(at clusterTime:Mongo.Instant?) -> Self
    {
        .level(.snapshot, at: clusterTime)
    }
    public static
    var snapshot:Self
    {
        .level(.snapshot, at: nil)
    }
}
extension Mongo.ReadConcern:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["level"] = self.level

        switch self.ordering
        {
        case nil:
            break
        case .at(let time)?:
            bson["atClusterTime"] = time
        case .after(let time)?:
            bson["afterClusterTime"] = time
        }
    }
}
