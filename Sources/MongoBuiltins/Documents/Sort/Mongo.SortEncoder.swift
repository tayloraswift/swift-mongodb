import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<Mongo.AnyKeyPath>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<Mongo.AnyKeyPath>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.SortEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension Mongo.SortEncoder
{
    @available(*, unavailable, message: """
        pass the `(+)` or `(-)` operator functions to specify sort direction.
        """)
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Int?
    {
        get { nil }
        set {     }
    }
}
extension Mongo.SortEncoder
{
    @frozen public
    enum Natural:String, Hashable, Sendable
    {
        case natural = "$natural"
    }

    @inlinable public
    subscript<Direction>(natural:Natural) -> ((Direction) -> Never)?
        where Direction:Mongo.SortDirection
    {
        get { nil }
        set (value)
        {
            if  case _? = value
            {
                Direction.code.encode(to: &self.bson[with: natural])
            }
        }
    }
}
extension Mongo.SortEncoder
{
    @inlinable public
    subscript<Direction>(path:Mongo.AnyKeyPath) -> ((Direction) -> Never)?
        where Direction:Mongo.SortDirection
    {
        get { nil }
        set (value)
        {
            if  case _? = value
            {
                Direction.code.encode(to: &self.bson[with: path.stem])
            }
        }
    }
}
extension Mongo.SortEncoder
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.SortOperatorEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path.stem][as: Mongo.SortOperatorEncoder.self])
        }
    }

    @available(*, deprecated, message: "Use the functional subscript instead.")
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.SortOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
