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
    var type:BSON.AnyType { .document }
}
extension Mongo.ExpressionEncoder
{
    @inlinable public
    subscript<Encodable>(key:Mongo.Expression.Unary) -> Encodable?
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

    /// Creates a `$not` or `$isArray` expression. This subscript already
    /// brackets the expression when passing it in an argument tuple;
    /// doing so manually will create an expression that always evaluates
    /// to false for `$not` (because an array evaluates to true),
    /// or true for `$isArray` (because an array is an array).
    @inlinable public
    subscript<Encodable>(key:Mongo.Expression.UnaryParenthesized) -> Encodable?
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
                    $0.append(value)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<First, Second>(key:Mongo.Expression.Binary) -> (_:First?, _:Second?)
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
                    $0.append(first)
                    $0.append(second)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Predicate, Then, Else>(
        key:Mongo.Expression.Cond) -> (if:Predicate?, then:Then?, else:Else?)
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
                    $0.append(predicate)
                    $0.append(first)
                    $0.append(second)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Dividend, Divisor>(key:Mongo.Expression.Division) -> (_:Dividend?, by:Divisor?)
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
                    $0.append(dividend)
                    $0.append(divisor)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Array, Index>(key:Mongo.Expression.Element) -> (of:Array?, at:Index?)
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
                    $0.append(array)
                    $0.append(index)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Encodable, Array>(key:Mongo.Expression.In) -> (_:Encodable?, in:Array?)
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
                    $0.append(element)
                    $0.append(array)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Base, Exponential>(key:Mongo.Expression.Log) -> (base:Base?, of:Exponential?)
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
                    $0.append(base)
                    $0.append(exponential)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Base, Exponent>(key:Mongo.Expression.Pow) -> (base:Base?, to:Exponent?)
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
                    $0.append(base)
                    $0.append(exponent)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Fraction>(key:Mongo.Expression.Quantization) -> Fraction?
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
    subscript<Fraction, Places>(
        key:Mongo.Expression.Quantization) -> (_:Fraction?, places:Places?)
        where   Fraction:BSONEncodable,
                Places:BSONEncodable
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
                    $0.append(fraction)
                    $0.push(places)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Start, End, Step>(key:Mongo.Expression.Range) -> (from:Start?, to:End?, by:Step?)
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
            if  case (from: let start?, to: let end?, by: let step) = value
            {
                {
                    $0.append(start)
                    $0.append(end)
                    $0.push(step)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Start, End>(key:Mongo.Expression.Range) -> (from:Start?, to:End?)
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
    subscript<Array, Index, Distance>(
        key:Mongo.Expression.Slice) -> (_:Array?, at:Index?, distance:Distance?)
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
            if  case (let array?, at: let index, distance: let distance?) = value
            {
                {
                    $0.append(array)
                    $0.push(index)
                    $0.append(distance)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Array, Distance>(key:Mongo.Expression.Slice) -> (_:Array?, distance:Distance?)
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
    subscript<Minuend, Difference>(
        key:Mongo.Expression.Subtract) -> (_:Minuend?, minus:Difference?)
        where   Minuend:BSONEncodable,
                Difference:BSONEncodable
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
                    $0.append(minuend)
                    $0.append(difference)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Count, Array>(key:Mongo.Expression.Superlative) -> (_:Count?, of:Array?)
        where   Count:BSONEncodable,
                Array:BSONEncodable
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
                    $0.append(count)
                    $0.append(array)
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Encodable>(key:Mongo.Expression.Variadic) -> Encodable?
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
    subscript<T0, T1>(key:Mongo.Expression.Variadic) -> (T0?, T1?)
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
                $0.push(value.0)
                $0.push(value.1)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
    @inlinable public
    subscript<T0, T1, T2>(key:Mongo.Expression.Variadic) -> (T0?, T1?, T2?)
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
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
    @inlinable public
    subscript<T0, T1, T2, T3>(key:Mongo.Expression.Variadic) -> (T0?, T1?, T2?, T3?)
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
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
                $0.push(value.3)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }
}

extension Mongo.ExpressionEncoder
{
    @inlinable public
    subscript(key:Mongo.Expression.Filter) -> Mongo.FilterDocument?
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
    subscript(key:Mongo.Expression.Map) -> Mongo.MapDocument?
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
    subscript(key:Mongo.Expression.Reduce) -> Mongo.ReduceDocument?
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
    subscript(key:Mongo.Expression.SortArray) -> Mongo.SortArrayDocument?
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
    subscript(key:Mongo.Expression.Switch) -> Mongo.SwitchDocument?
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
    subscript(key:Mongo.Expression.Zip) -> Mongo.ZipDocument?
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
    @inlinable public
    subscript<Sequence, Element, Start, End>(
        key:Mongo.Expression.Index) -> (in:Sequence?, of:Element?, from:Start?, to:End?)
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
                    $0.append(sequence)
                    $0.append(element)

                    if  let start:Start
                    {
                        $0.append(start)
                        $0.push(end)
                    }
                } (&self.bson[with: key][as: BSON.ListEncoder.self])
            }
        }
    }
    @inlinable public
    subscript<Sequence, Element>(key:Mongo.Expression.Index) -> (in:Sequence?, of:Element?)
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
