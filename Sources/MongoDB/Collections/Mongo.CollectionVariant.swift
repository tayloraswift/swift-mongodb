import BSON
import BSONDSL

extension Mongo
{
    @frozen public
    enum CollectionVariant:Sendable
    {
        case collection(cap:(size:Int, max:Int?)? = nil,
            validationAction:ValidationAction? = nil,
            validationLevel:ValidationLevel? = nil,
            validator:PredicateDocument? = nil)
        
        case timeseries(Timeseries)

        case view(CollectionView)
    }
}
extension Mongo.CollectionVariant
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
