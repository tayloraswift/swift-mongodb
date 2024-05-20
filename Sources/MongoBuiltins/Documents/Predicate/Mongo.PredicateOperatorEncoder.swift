import BSON

extension Mongo
{
    @frozen public
    struct PredicateOperatorEncoder:Sendable
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
extension Mongo.PredicateOperatorEncoder:BSON.Encoder
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

extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Binary:String, Sendable
    {
        case bitsAllClear   = "$bitsAllClear"
        case bitsAllSet     = "$bitsAllSet"
        case bitsAnyClear   = "$bitsAnyClear"
        case bitsAnySet     = "$bitsAnySet"

        case eq             = "$eq"
        case gt             = "$gt"
        case gte            = "$gte"
        case lt             = "$lt"
        case lte            = "$lte"
        case ne             = "$ne"

        case size           = "$size"
    }

    @inlinable public
    subscript<Encodable>(key:Binary) -> Encodable?
        where Encodable:BSONEncodable
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
extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Exists:String, Sendable
    {
        case exists = "$exists"
    }

    @inlinable public
    subscript(key:Exists) -> Bool?
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
extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Metatype:String, Sendable
    {
        case type = "$type"
    }

    @inlinable public
    subscript(key:Metatype) -> BSON.AnyType?
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
    subscript(key:Metatype) -> [BSON.AnyType]?
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
extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Mod:String, Sendable
    {
        case mod = "$mod"
    }

    @inlinable public
    subscript<Divisor, Remainder>(key:Mod) -> (by:Divisor?, is:Remainder?)
        where Divisor:BSONEncodable, Remainder:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            guard
            let divisor:Divisor = value.by,
            let remainder:Remainder = value.is
            else
            {
                return
            }

            {
                $0.append(divisor)
                $0.append(remainder)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
}
extension Mongo.PredicateOperator
{
    @frozen public
    enum Recursive:String, Sendable
    {
        case not = "$not"
        case any = "$elemMatch"

        @available(*, unavailable, renamed: "any")
        public static
        var elemMatch:Self { .any }
    }

    @inlinable public
    subscript(key:Recursive) -> Self?
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
extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Regex:String, Sendable
    {
        case regex = "$regex"
    }

    @inlinable public
    subscript(key:Regex) -> BSON.Regex?
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
extension Mongo.PredicateOperatorEncoder
{
    @frozen public
    enum Variadic:String, Sendable
    {
        case all    = "$all"
        case `in`   = "$in"
        case nin    = "$nin"
    }

    @inlinable public
    subscript<Encodable>(key:Variadic) -> Encodable?
        where Encodable:BSONEncodable
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
