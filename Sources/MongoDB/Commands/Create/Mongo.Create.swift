import BSONEncoding

extension Mongo
{
    /// Explicitly creates a collection or view.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/create/
    public
    struct Create:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        var fields:BSON.Fields

        public
        init(collection:Collection,
            collation:Collation? = nil,
            writeConcern:WriteConcern? = nil,
            indexOptionDefaults:StorageConfiguration? = nil,
            storageEngine:StorageConfiguration? = nil,
            variant:Variant = .collection())
        {
            self.writeConcern = writeConcern

            self.fields = .init
            {
                $0[Self.name] = collection
                $0["collation"] = collation
                $0["indexOptionDefaults", elide: true] = indexOptionDefaults
                $0["storageEngine", elide: true] = storageEngine

                switch variant
                {
                case .collection(cap: let cap,
                    validationAction: let action,
                    validationLevel: let level,
                    validator: let validator):

                    if let cap:Mongo.Cap
                    {
                        $0["capped"] = true
                        $0["size"] = cap.size
                        $0["max"] = cap.max
                    }

                    $0["validator", elide: true] = validator
                    $0["validationAction"] = action
                    $0["validationLevel"] = level
                
                case .timeseries(let timeseries):
                    $0["timeseries"] = timeseries
                
                case .view(on: let collection, pipeline: let pipeline):
                    // don’t elide pipeline, it should always be there
                    $0["viewOn"] = collection
                    $0["pipeline", elide: false] = pipeline
                }
            }
        }
    }
}
extension Mongo.Create:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"create"`]().
    @inlinable public static
    var name:String
    {
        "create"
    }
}
