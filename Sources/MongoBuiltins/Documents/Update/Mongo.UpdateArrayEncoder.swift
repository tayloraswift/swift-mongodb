import BSON

extension Mongo
{
    @frozen public
    struct UpdateArrayEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.UpdateArrayEncoder:BSON.Encoder
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

extension Mongo.UpdateArrayEncoder
{
    @frozen public
    enum Each:String, Sendable
    {
        case each = "$each"
    }

    @inlinable public
    subscript<Array>(key:Each) -> Array? where Array:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.UpdateArrayEncoder
{
    @frozen public
    enum Index:String, Sendable
    {
        case position = "$position"
        case sort = "$sort"
    }

    @inlinable public
    subscript(key:Index) -> Int?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.UpdateArrayEncoder
{
    @frozen public
    enum Sort:String, Sendable
    {
        case sort = "$sort"
    }

    @inlinable public
    subscript<CodingKey>(key:Sort,
        using _:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SortEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.SortEncoder<CodingKey>.self])
        }
    }
}
