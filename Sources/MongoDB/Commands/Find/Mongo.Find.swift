import BSONEncoding
import Durations
import MongoSchema

extension Mongo
{
    public
    struct Find<Element>:Sendable where Element:MongoDecodable
    {
        public
        let readConcern:ReadConcern?
        public
        let tailing:Tailing?
        public
        let stride:Int

        public
        var fields:BSON.Fields

        public
        init(collection:Collection,
            tailing:Tailing? = nil,
            stride:Int,
            limit:Int? = nil,
            skip:Int? = nil,
            filter:PredicateDocument = [:],
            projection:ProjectionDocument = [:],
            hint:IndexHint? = nil,
            sort:SortDocument = [:],
            `let`:LetDocument = [:],
            collation:Collation? = nil,
            readConcern:ReadConcern? = nil,
            min:BSON.Fields = [:],
            max:BSON.Fields = [:],
            returnKey:Bool? = nil,
            showRecordIdentifier:Bool? = nil)
        {
            self.readConcern = readConcern
            self.tailing = tailing
            self.stride = stride

            self.fields = .init
            {
                $0[Self.name] = collection
                $0["batchSize"] = stride
                $0["tailable"] = tailing.map { _ in true }
                $0["awaitData"] = tailing.flatMap { $0.awaits ? true : nil }
                    
                $0["let", elide: true] = `let`
                $0["filter", elide: true] = filter
                $0["sort", elide: true] = sort
                $0["projection", elide: true] = projection
                    
                $0["skip"] = skip
                $0["limit"] = limit

                $0["collation"] = collation
                    
                $0["hint"] = hint
                $0["min", elide: true] = min
                $0["max", elide: true] = max
                    
                $0["returnKey"] = returnKey
                $0["showRecordId"] = showRecordIdentifier
            }
        }
    }
}
extension Mongo.Find:MongoIterableCommand
{
    public
    typealias Response = Mongo.Cursor<Element>
}
extension Mongo.Find:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"find"`]().
    @inlinable public static
    var name:String
    {
        "find"
    }
}
