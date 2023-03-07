import BSON
import BSONDSL

extension Mongo.CollectionOptions
{
    @frozen public
    enum Variant:Sendable
    {
        case collection(cap:(size:Int, max:Int?)? = nil,
            validationAction:Mongo.ValidationAction? = nil,
            validationLevel:Mongo.ValidationLevel? = nil,
            validator:Mongo.PredicateDocument? = nil)
        
        case timeseries(Mongo.Timeseries)

        case view(Mongo.CollectionView)
    }
}
extension Mongo.CollectionOptions.Variant
{
    @inlinable public
    var type:Mongo.CollectionType
    {
        switch self
        {
        case .collection:   return .collection
        case .timeseries:   return .timeseries
        case .view:         return .view
        }
    }
    @inlinable public
    var cap:(size:Int, max:Int?)?
    {
        switch self
        {
        case .collection(cap: let cap?, validationAction: _, validationLevel: _, validator: _):
            return cap
        default:
            return nil
        }
    }
    @inlinable public
    var timeseries:Mongo.Timeseries?
    {
        switch self
        {
        case .timeseries(let timeseries):
            return timeseries
        default:
            return nil
        }
    }
    @inlinable public
    var view:Mongo.CollectionView?
    {
        switch self
        {
        case .view(let view):
            return view
        default:
            return nil
        }
    }
}
