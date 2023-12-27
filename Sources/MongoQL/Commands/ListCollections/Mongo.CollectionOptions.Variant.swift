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
        case .collection:   .collection
        case .timeseries:   .timeseries
        case .view:         .view
        }
    }
    @inlinable public
    var cap:(size:Int, max:Int?)?
    {
        switch self
        {
        case .collection(cap: let cap?, validationAction: _, validationLevel: _, validator: _):
            cap
        default:
            nil
        }
    }
    @inlinable public
    var timeseries:Mongo.Timeseries?
    {
        switch self
        {
        case .timeseries(let timeseries):
            timeseries
        default:
            nil
        }
    }
    @inlinable public
    var view:Mongo.CollectionView?
    {
        switch self
        {
        case .view(let view):
            view
        default:
            nil
        }
    }
}
