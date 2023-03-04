import BSONEncoding

extension Mongo.ReadConcern
{
    struct Options:Sendable
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
extension Mongo.ReadConcern.Options
{
    init(level:Mongo.ReadConcern.Level?, after clusterTime:Mongo.Timestamp?)
    {
        self.init(ordering: clusterTime.map(Mongo.ReadConcern.Ordering.after(_:)),
            level: level)
    }
    init(level:Mongo.ReadConcern.Level?, at clusterTime:Mongo.Timestamp?)
    {
        self.init(ordering: clusterTime.map(Mongo.ReadConcern.Ordering.at(_:)),
            level: level)
    }
}
extension Mongo.ReadConcern.Options:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
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
