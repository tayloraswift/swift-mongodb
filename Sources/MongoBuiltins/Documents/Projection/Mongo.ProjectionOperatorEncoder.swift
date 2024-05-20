import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ProjectionOperatorEncoder:Sendable
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
extension Mongo.ProjectionOperatorEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output) { self.init(bson: .init(output)) }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.ProjectionOperatorEncoder
{
    @frozen public
    enum First:String, Sendable
    {
        case first = "$elemMatch"

        @available(*, unavailable, renamed: "first")
        public static
        var elemMatch:Self { .first }
    }

    @inlinable public
    subscript(key:First, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.PredicateEncoder.self])
        }
    }

    @inlinable public
    subscript<Predicate>(key:First) -> Predicate? where Predicate:Mongo.PredicateEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key][as: Mongo.PredicateEncoder.self])
        }
    }

    @available(*, deprecated)
    @inlinable public
    subscript(key:First) -> Mongo.PredicateDocument?
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
extension Mongo.ProjectionOperatorEncoder
{
    @frozen public
    enum Meta:String, Sendable
    {
        case meta = "$meta"
    }

    @inlinable public
    subscript(key:Meta) -> Mongo.ProjectionMetadata?
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
extension Mongo.ProjectionOperatorEncoder
{
    /// Not to be confused with ``Mongo/ExpressionEncoder.Slice`` which can also appear in the
    /// same position as this operator.
    @frozen public
    enum Slice:String, Sendable
    {
        case slice = "$slice"
    }

    @inlinable public
    subscript(key:Slice) -> Int?
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

    @inlinable public
    subscript(key:Slice) -> (at:Int?, count:Int?)
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            guard let count:Int = value.count
            else
            {
                return
            }

            {
                if let index:Int = value.at
                {
                    $0.append(index)
                }
                $0.append(count)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
}
