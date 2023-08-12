import BSONDecoding
import BSONEncoding

@available(*, deprecated, renamed: "Mongo.Expression")
public
typealias MongoExpression = Mongo.Expression

extension Mongo
{
    @frozen public
    struct Expression:BSONRepresentable, BSONDecodable, BSONEncodable, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.Expression
{
    @inlinable public
    subscript<Encodable>(key:Unary) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
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
            if let value:Encodable
            {
                self.bson[key]
                {
                    $0.append(value)
                }
            }
        }
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
            if case (let first?, let second?) = value
            {
                self.bson[key]
                {
                    $0.append(first)
                    $0.append(second)
                }
            }
        }
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
            if case (if: let predicate?, then: let first?, else: let second?) = value
            {
                self.bson[key]
                {
                    $0.append(predicate)
                    $0.append(first)
                    $0.append(second)
                }
            }
        }
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
            if case (let dividend?, by: let divisor?) = value
            {
                self.bson[key]
                {
                    $0.append(dividend)
                    $0.append(divisor)
                }
            }
        }
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
            if case (of: let array?, at: let index?) = value
            {
                self.bson[key]
                {
                    $0.append(array)
                    $0.append(index)
                }
            }
        }
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
            if case (let element?, in: let array?) = value
            {
                self.bson[key]
                {
                    $0.append(element)
                    $0.append(array)
                }
            }
        }
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
            if case (base: let base?, of: let exponential?) = value
            {
                self.bson[key]
                {
                    $0.append(base)
                    $0.append(exponential)
                }
            }
        }
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
            if case (base: let base?, to: let exponent?) = value
            {
                self.bson[key]
                {
                    $0.append(base)
                    $0.append(exponent)
                }
            }
        }
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
        where   Fraction:BSONEncodable,
                Places:BSONEncodable
    {
        get
        {
            (nil, places: nil)
        }
        set(value)
        {
            if case (let fraction?, let places) = value
            {
                self.bson[key]
                {
                    $0.append(fraction)
                    $0.push(places)
                }
            }
        }
    }

    @inlinable public
    subscript<Start, End, Step>(key:Range) -> (from:Start?, to:End?, by:Step?)
        where   Start:BSONEncodable,
                End:BSONEncodable,
                Step:BSONEncodable
    {
        get
        {
            (from: nil, to: nil, by: nil)
        }
        set(value)
        {
            if case (from: let start?, to: let end?, by: let step) = value
            {
                self.bson[key]
                {
                    $0.append(start)
                    $0.append(end)
                    $0.push(step)
                }
            }
        }
    }
    @inlinable public
    subscript<Start, End>(key:Range) -> (from:Start?, to:End?)
        where   Start:BSONEncodable,
                End:BSONEncodable
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

    @inlinable public
    subscript<Array, Index, Distance>(key:Slice) -> (_:Array?, at:Index?, distance:Distance?)
        where   Array:BSONEncodable,
                Index:BSONEncodable,
                Distance:BSONEncodable
    {
        get
        {
            (nil, at: nil, distance: nil)
        }
        set(value)
        {
            if case (let array?, at: let index, distance: let distance?) = value
            {
                self.bson[key]
                {
                    $0.append(array)
                    $0.push(index)
                    $0.append(distance)
                }
            }
        }
    }
    @inlinable public
    subscript<Array, Distance>(key:Slice) -> (_:Array?, distance:Distance?)
        where   Array:BSONEncodable,
                Distance:BSONEncodable
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

    @inlinable public
    subscript<Minuend, Difference>(key:Subtract) -> (_:Minuend?, minus:Difference?)
        where   Minuend:BSONEncodable,
                Difference:BSONEncodable
    {
        get
        {
            (nil, minus: nil)
        }
        set(value)
        {
            if case (let minuend?, minus: let difference?) = value
            {
                self.bson[key]
                {
                    $0.append(minuend)
                    $0.append(difference)
                }
            }
        }
    }

    @inlinable public
    subscript<Count, Array>(key:Superlative) -> (_:Count?, of:Array?)
        where   Count:BSONEncodable,
                Array:BSONEncodable
    {
        get
        {
            (nil, of: nil)
        }
        set(value)
        {
            if case (let count?, of: let array?) = value
            {
                self.bson[key]
                {
                    $0.append(count)
                    $0.append(array)
                }
            }
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
            self.bson.push(key, value)
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
            self.bson[key]
            {
                $0.push(value.0)
                $0.push(value.1)
            }
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
            self.bson[key]
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            }
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
            self.bson[key]
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
                $0.push(value.3)
            }
        }
    }
}

extension Mongo.Expression
{
    @inlinable public
    subscript(key:Filter) -> Mongo.FilterDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
    }
}

extension Mongo.Expression
{
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
            if case (in: let sequence?, of: let element?, let start, let end) = value
            {
                self.bson[key]
                {
                    $0.append(sequence)
                    $0.append(element)

                    if let start:Start
                    {
                        $0.append(start)
                        $0.push(end)
                    }
                }
            }
        }
    }
    @inlinable public
    subscript<Sequence, Element>(key:Index) -> (in:Sequence?, of:Element?)
        where   Sequence:BSONEncodable,
                Element:BSONEncodable
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