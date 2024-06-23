import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortEncoder<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<CodingKey>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<CodingKey>)
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
    var frame:BSON.DocumentFrame { .document }
}
extension Mongo.SortEncoder
{
    @available(*, unavailable, message: """
        pass the `(+)` or `(-)` operator functions to specify sort direction.
        """)
    @inlinable public
    subscript(path:CodingKey) -> Int?
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
    subscript<Direction>(path:CodingKey) -> ((Direction) -> Never)?
        where Direction:Mongo.SortDirection
    {
        get { nil }
        set (value)
        {
            if  case _? = value
            {
                Direction.code.encode(to: &self.bson[with: path])
            }
        }
    }
}
extension Mongo.SortEncoder
{
    @inlinable public
    subscript(path:CodingKey, yield:(inout Mongo.SortOperatorEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.SortOperatorEncoder.self])
        }
    }
}
