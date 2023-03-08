import BSONDecoding
import BSONDSL

extension Mongo
{
    /// Collection options.
    @frozen public
    struct CollectionOptions:Sendable
    {
        public
        let collation:Collation?
        public
        let writeConcern:WriteConcern.Options?
        public
        let indexOptionDefaults:BSON.Document?
        public
        let storageEngine:BSON.Document?

        public
        let variant:Variant

        public
        init(collation:Collation?,
            writeConcern:WriteConcern.Options?,
            indexOptionDefaults:BSON.Document?,
            storageEngine:BSON.Document?,
            variant:Variant)
        {
            self.collation = collation
            self.writeConcern = writeConcern
            self.indexOptionDefaults = indexOptionDefaults
            self.storageEngine = storageEngine
            self.variant = variant
        }
    }
}
extension Mongo.CollectionOptions
{
    @inlinable public
    var capped:Bool
    {
        if case _? = self.variant.cap
        {
            return true
        }
        else
        {
            return false
        }
    }
    @inlinable public
    var size:Int?
    {
        self.variant.cap?.size
    }
    @inlinable public
    var max:Int?
    {
        self.variant.cap?.max
    }
    @inlinable public
    var validationAction:Mongo.ValidationAction?
    {
        switch self.variant
        {
        case .collection(cap: _, validationAction: let action, validationLevel: _, validator: _):
            return action
        default:
            return nil
        }
    }
    @inlinable public
    var validationLevel:Mongo.ValidationLevel?
    {
        switch self.variant
        {
        case .collection(cap: _, validationAction: _, validationLevel: let level, validator: _):
            return level
        default:
            return nil
        }
    }
    @inlinable public
    var timeseries:Mongo.Timeseries?
    {
        self.variant.timeseries
    }
    @inlinable public
    var viewOn:Mongo.Collection?
    {
        self.variant.view?.collection
    }
    @inlinable public
    var pipeline:Mongo.Pipeline?
    {
        self.variant.view?.pipeline
    }
}
extension Mongo.CollectionOptions
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>,
        type:Mongo.CollectionType) throws
    {
        let variant:Variant
        switch type
        {
        case .collection:
            let cap:(size:Int, max:Int?)?
            if case true? = try bson["capped"]?.decode(to: Bool.self)
            {
                cap =
                (
                    size: try bson["size"].decode(to: Int.self),
                    max: try bson["max"]?.decode(to: Int.self)
                )
            }
            else
            {
                cap = nil
            }
            variant = .collection(cap: cap,
                validationAction: try bson["validationAction"]?.decode(
                    to: Mongo.ValidationAction.self),
                validationLevel: try bson["validationLevel"]?.decode(
                    to: Mongo.ValidationLevel.self),
                validator: try bson["validator"]?.decode(
                    to: Mongo.PredicateDocument.self))
        
        case .timeseries:
            variant = .timeseries(try bson["timeseries"].decode(to: Mongo.Timeseries.self))
        
        case .view:
            variant = .view(.init(on: try bson["viewOn"].decode(to: Mongo.Collection.self),
                pipeline: try bson["pipeline"].decode(to: Mongo.Pipeline.self)))
        }
        self.init(
            collation: try bson["collation"]?.decode(to: Mongo.Collation.self),
            writeConcern: try bson["writeConcern"]?.decode(to: Mongo.WriteConcern.Options.self),
            indexOptionDefaults: try bson["indexOptionDefaults"]?.decode(
                to: BSON.Document.self),
            storageEngine: try bson["storageEngine"]?.decode(
                to: BSON.Document.self),
            variant: variant)
    }
}
