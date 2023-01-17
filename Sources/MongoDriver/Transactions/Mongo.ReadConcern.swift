import BSONEncoding

extension Mongo
{
    public
    struct ReadConcern
    {
        let ordering:Ordering?
        let level:Level?

        init(ordering:Ordering?, level:Level?)
        {
            self.ordering = ordering
            self.level = level
        }
    }
}
extension Mongo.ReadConcern
{
    public
    init(level:Mongo.ReadLevel?, after clusterTime:Mongo.Instant?)
    {
        self.init(ordering: clusterTime.map(Ordering.after(_:)),
            level: level.map(Level.init(_:)))
    }
}
extension Mongo.ReadConcern:BSONDocumentEncodable
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
// extension Mongo.ReadConcern:BSONDictionaryDecodable
// {
//     @inlinable public
//     init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
//     {
//         switch try bson["level"].decode(to: Level.self)
//         {
//         case .local:
//             self = .local
//         case .available:
//             self = .available
//         case .majority:
//             self = .majority
//         case .linearizable:
//             self = .linearizable
//         case .snapshot:
//             self = .snapshot(at: bson[""])
//         }
//         self.init(level: )
//     }
// }
