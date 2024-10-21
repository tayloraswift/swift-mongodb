import BSON

extension Mongo
{
    @frozen public
    struct ExpressionEncoder:Sendable
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
extension Mongo.ExpressionEncoder:BSON.Encoder
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Unary:String, Sendable
    {
        case abs            = "$abs"
        case arrayToObject  = "$arrayToObject"
        case binarySize     = "$binarySize"
        case objectSize     = "$bsonSize"
        case objectToArray  = "$objectToArray"
        case ceil           = "$ceil"
        case exp            = "$exp"
        case first          = "$first"
        case floor          = "$floor"
        case last           = "$last"
        case literal        = "$literal"
        case ln             = "$ln"
        case log10          = "$log10"
        case reverseArray   = "$reverseArray"
        case size           = "$size"
        case sqrt           = "$sqrt"
    }

    @inlinable public
    subscript<Encodable>(key:Unary) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:Unary, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.ExpressionEncoder.self])
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum UnaryParenthesized:String, Sendable
    {
        case isArray            = "$isArray"
        case not                = "$not"
        case type               = "$type"

        case allElementsTrue    = "$allElementsTrue"
        case anyElementTrue     = "$anyElementTrue"
    }

    /// Creates a `$not` or `$isArray` expression. This subscript already
    /// brackets the expression when passing it in an argument tuple;
    /// doing so manually will create an expression that always evaluates
    /// to false for `$not` (because an array evaluates to true),
    /// or true for `$isArray` (because an array is an array).
    @inlinable public
    subscript<Encodable>(key:UnaryParenthesized) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Encodable
            {
                {
                    $0[+] = value
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Binary:String, Sendable
    {
        case cmp    = "$cmp"
        case eq     = "$eq"
        case gt     = "$gt"
        case gte    = "$gte"
        case lt     = "$lt"
        case lte    = "$lte"
        case ne     = "$ne"

        case setDifference = "$setDifference"
        case setIsSubset = "$setIsSubset"
    }

    @inlinable public
    subscript<First, Second>(key:Binary) -> (_:First?, _:Second?)
        where   First:BSONEncodable,
                Second:BSONEncodable
    {
        get
        {
            (of: nil, at: nil)
        }
        set(value)
        {
            if  case (let first?, let second?) = value
            {
                {
                    $0[+] = first
                    $0[+] = second
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Cond:String, Sendable
    {
        case cond = "$cond"
    }

    @inlinable public
    subscript<Predicate, Then, Else>(key:Cond) -> (if:Predicate?, then:Then?, else:Else?)
        where   Predicate:BSONEncodable,
                Then:BSONEncodable,
                Else:BSONEncodable
    {
        get
        {
            (nil, nil, nil)
        }
        set(value)
        {
            if  case (if: let predicate?, then: let first?, else: let second?) = value
            {
                {
                    $0[+] = predicate
                    $0[+] = first
                    $0[+] = second
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Division:String, Sendable
    {
        case divide = "$divide"
        case mod    = "$mod"
    }

    @inlinable public
    subscript<Dividend, Divisor>(key:Division) -> (_:Dividend?, by:Divisor?)
        where   Dividend:BSONEncodable,
                Divisor:BSONEncodable
    {
        get
        {
            (nil, by: nil)
        }
        set(value)
        {
            if  case (let dividend?, by: let divisor?) = value
            {
                {
                    $0[+] = dividend
                    $0[+] = divisor
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Element:String, Sendable
    {
        case element = "$arrayElemAt"

        @available(*, unavailable, renamed: "element")
        public static
        var arrayElemAt:Self { .element }
    }


    @inlinable public
    subscript<Array, Index>(key:Element) -> (of:Array?, at:Index?)
        where   Array:BSONEncodable,
                Index:BSONEncodable
    {
        get
        {
            (of: nil, at: nil)
        }
        set(value)
        {
            if  case (of: let array?, at: let index?) = value
            {
                {
                    $0[+] = array
                    $0[+] = index
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum In:String, Sendable
    {
        case `in` = "$in"
    }

    @inlinable public
    subscript<Encodable, Array>(key:In) -> (_:Encodable?, in:Array?)
        where   Encodable:BSONEncodable,
                Array:BSONEncodable
    {
        get
        {
            (nil, in: nil)
        }
        set(value)
        {
            if  case (let element?, in: let array?) = value
            {
                {
                    $0[+] = element
                    $0[+] = array
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Log:String, Sendable
    {
        case log = "$log"
    }

    @inlinable public
    subscript<Base, Exponential>(key:Log) -> (base:Base?, of:Exponential?)
        where   Base:BSONEncodable,
                Exponential:BSONEncodable
    {
        get
        {
            (base: nil, of: nil)
        }
        set(value)
        {
            if  case (base: let base?, of: let exponential?) = value
            {
                {
                    $0[+] = base
                    $0[+] = exponential
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Pow:String, Sendable
    {
        case pow = "$pow"
    }

    @inlinable public
    subscript<Base, Exponent>(key:Pow) -> (base:Base?, to:Exponent?)
        where   Base:BSONEncodable,
                Exponent:BSONEncodable
    {
        get
        {
            (base: nil, to: nil)
        }
        set(value)
        {
            if  case (base: let base?, to: let exponent?) = value
            {
                {
                    $0[+] = base
                    $0[+] = exponent
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Quantization:String, Sendable
    {
        case round = "$round"
        case trunc = "$trunc"
    }

    @inlinable public
    subscript<Fraction>(key:Quantization) -> Fraction?
        where Fraction:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self[key] = (value, nil as Int32?)
        }
    }
    @inlinable public
    subscript<Fraction, Places>(key:Quantization) -> (_:Fraction?, places:Places?)
        where Fraction:BSONEncodable, Places:BSONEncodable
    {
        get
        {
            (nil, places: nil)
        }
        set(value)
        {
            if  case (let fraction?, let places) = value
            {
                {
                    $0[+] = fraction
                    $0[+] = places
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Range:String, Sendable
    {
        case range = "$range"
    }

    @inlinable public
    subscript<Start, End, Step>(key:Range) -> (from:Start?, to:End?, by:Step?)
        where Start:BSONEncodable, End:BSONEncodable, Step:BSONEncodable
    {
        get
        {
            (from: nil, to: nil, by: nil)
        }
        set(value)
        {
            if  case (from: let start?, to: let end?, by: let step) = value
            {
                {
                    $0[+] = start
                    $0[+] = end
                    $0[+] = step
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Start, End>(key:Range) -> (from:Start?, to:End?)
        where Start:BSONEncodable, End:BSONEncodable
    {
        get
        {
            (from: nil, to: nil)
        }
        set(value)
        {
            self[key] = (from: value.from, to: value.to, by: nil as Never?)
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Slice:String, Sendable
    {
        case slice = "$slice"
    }

    @inlinable public
    subscript<Array, Index, Distance>(key:Slice) -> (_:Array?, at:Index?, distance:Distance?)
        where Array:BSONEncodable, Index:BSONEncodable, Distance:BSONEncodable
    {
        get
        {
            (nil, at: nil, distance: nil)
        }
        set(value)
        {
            if  case (let array?, at: let index, distance: let distance?) = value
            {
                {
                    $0[+] = array
                    $0[+] = index
                    $0[+] = distance
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Array, Distance>(key:Slice) -> (_:Array?, distance:Distance?)
        where Array:BSONEncodable, Distance:BSONEncodable
    {
        get
        {
            (nil, distance: nil)
        }
        set(value)
        {
            self[key] = (value.0, at: nil as Never?, distance: value.distance)
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Subtract:String, Sendable
    {
        case subtract = "$subtract"
    }

    @inlinable public
    subscript<Minuend, Difference>(key:Subtract) -> (_:Minuend?, minus:Difference?)
        where Minuend:BSONEncodable, Difference:BSONEncodable
    {
        get
        {
            (nil, minus: nil)
        }
        set(value)
        {
            if  case (let minuend?, minus: let difference?) = value
            {
                {
                    $0[+] = minuend
                    $0[+] = difference
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Superlative:String, Sendable
    {
        case first  = "$firstN"
        case last   = "$lastN"
        case max    = "$maxN"
        case min    = "$minN"

        @available(*, unavailable, renamed: "first")
        public static
        var firstN:Self { .first }
        @available(*, unavailable, renamed: "last")
        public static
        var lastN:Self { .last }
        @available(*, unavailable, renamed: "max")
        public static
        var maxN:Self { .max }
        @available(*, unavailable, renamed: "min")
        public static
        var minN:Self { .min }
    }

    @inlinable public
    subscript<Count, Array>(key:Superlative) -> (_:Count?, of:Array?)
        where Count:BSONEncodable, Array:BSONEncodable
    {
        get
        {
            (nil, of: nil)
        }
        set(value)
        {
            if  case (let count?, of: let array?) = value
            {
                {
                    $0[+] = count
                    $0[+] = array
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
}
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Variadic:String, Sendable
    {
        case add                = "$add"
        case and                = "$and"
        case coalesce           = "$ifNull"
        case concatArrays       = "$concatArrays"
        case multiply           = "$multiply"
        case or                 = "$or"
        case zip                = "$zip"

        case mergeObjects       = "$mergeObjects"

        case setEquals          = "$setEquals"
        case setIntersection    = "$setIntersection"
        case setUnion           = "$setUnion"

        @available(*, unavailable, renamed: "coalesce")
        public static
        var ifNull:Self { .coalesce }
    }

    @inlinable public
    subscript(key:Variadic,
        using:Int.Type = Int.self,
        yield:(inout Mongo.SetListEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.SetListEncoder.self])
        }
    }

    @inlinable public
    subscript(key:Variadic, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.ExpressionEncoder.self])
        }
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
    @inlinable public
    subscript<T0, T1>(key:Variadic) -> (T0?, T1?)
        where   T0:BSONEncodable,
                T1:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            {
                $0[+] = value.0
                $0[+] = value.1
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
    @inlinable public
    subscript<T0, T1, T2>(key:Variadic) -> (T0?, T1?, T2?)
        where   T0:BSONEncodable,
                T1:BSONEncodable,
                T2:BSONEncodable
    {
        get
        {
            (nil, nil, nil)
        }
        set(value)
        {
            {
                $0[+] = value.0
                $0[+] = value.1
                $0[+] = value.2
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
    @inlinable public
    subscript<T0, T1, T2, T3>(key:Variadic) -> (T0?, T1?, T2?, T3?)
        where   T0:BSONEncodable,
                T1:BSONEncodable,
                T2:BSONEncodable,
                T3:BSONEncodable
    {
        get
        {
            (nil, nil, nil, nil)
        }
        set(value)
        {
            {
                $0[+] = value.0
                $0[+] = value.1
                $0[+] = value.2
                $0[+] = value.3
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
}

extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Filter:String, Sendable
    {
        case filter = "$filter"
    }

    @inlinable public
    subscript(key:Filter) -> Mongo.FilterDocument?
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Map:String, Sendable
    {
        case map = "$map"
    }

    @inlinable public
    subscript(key:Map) -> Mongo.MapDocument?
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Reduce:String, Sendable
    {
        case reduce = "$reduce"
    }

    @inlinable public
    subscript(key:Reduce) -> Mongo.ReduceDocument?
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum SortArray:String, Sendable
    {
        case sortArray = "$sortArray"
    }

    @inlinable public
    subscript(key:SortArray) -> Mongo.SortArrayDocument?
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Switch:String, Sendable
    {
        case `switch` = "$switch"
    }

    @inlinable public
    subscript(key:Switch) -> Mongo.SwitchDocument?
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
extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Zip:String, Sendable
    {
        case zip = "$zip"
    }

    @inlinable public
    subscript(key:Zip) -> Mongo.ZipDocument?
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

extension Mongo.ExpressionEncoder
{
    @frozen public
    enum Index:String, Sendable
    {
        case elementIndex       = "indexOfArray"
        case unicodeScalarIndex = "indexOfCP"
        case utf8Index          = "indexOfBytes"

        @available(*, unavailable, renamed: "elementIndex")
        public static
        var indexOfArray:Self { .elementIndex }
        @available(*, unavailable, renamed: "unicodeScalarIndex")
        public static
        var indexOfCP:Self { .unicodeScalarIndex }
        @available(*, unavailable, renamed: "utf8Index")
        public static
        var indexOfBytes:Self { .utf8Index }
    }


    @inlinable public
    subscript<Sequence, Element, Start, End>(
        key:Index) -> (in:Sequence?, of:Element?, from:Start?, to:End?)
        where   Sequence:BSONEncodable,
                Element:BSONEncodable,
                Start:BSONEncodable,
                End:BSONEncodable
    {
        get
        {
            (in: nil, of: nil, from: nil, to: nil)
        }
        set(value)
        {
            if  case (in: let sequence?, of: let element?, let start, let end) = value
            {
                {
                    $0[+] = sequence
                    $0[+] = element

                    if  let start:Start
                    {
                        $0[+] = start
                        $0[+] = end
                    }
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Sequence, Element>(key:Index) -> (in:Sequence?, of:Element?)
        where Sequence:BSONEncodable, Element:BSONEncodable
    {
        get
        {
            (in: nil, of: nil)
        }
        set(value)
        {
            self[key] = (value.0, value.1, nil as Never?, nil as Never?)
        }
    }
}
