import BSONEncoding

@frozen public
struct MongoExpression
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoExpression:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpression:MongoExpressionEncodable
{
}

//  These overloads are unique to ``MongoExpression``, because it has
//  operators that take multiple arguments. The other DSLs don't need these.
extension MongoExpression?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}

extension MongoExpression
{
    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
}
extension MongoExpression
{
    @inlinable public
    subscript<Encodable>(key:Unary) -> Encodable?
        where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }

    /// Creates a `$not` or `$isArray` expression. This subscript already
    /// brackets the expression when passing it in an argument tuple;
    /// doing so manually will create an expression that always evaluates
    /// to false for `$not` (because an array evaluates to true),
    /// or true for `$isArray` (because an array is an array).
    @inlinable public
    subscript<Encodable>(key:UnaryParenthesized) -> Encodable?
        where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = .init
            {
                $0.append(value)
            }
        }
    }

    @inlinable public
    subscript<First, Second>(key:Binary) -> (_:First?, _:Second?)
        where   First:MongoExpressionEncodable,
                Second:MongoExpressionEncodable
    {
        get
        {
            (of: nil, at: nil)
        }
        set(value)
        {
            if case (let first?, let second?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(first)
                    $0.append(second)
                }
            }
        }
    }

    @inlinable public
    subscript<Array, Index>(key:Element) -> (of:Array?, at:Index?)
        where   Array:MongoExpressionEncodable,
                Index:MongoExpressionEncodable
    {
        get
        {
            (of: nil, at: nil)
        }
        set(value)
        {
            if case (of: let array?, at: let index?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(array)
                    $0.append(index)
                }
            }
        }
    }

    @inlinable public
    subscript<Dividend, Divisor>(key:Division) -> (_:Dividend?, by:Divisor?)
        where   Dividend:MongoExpressionEncodable,
                Divisor:MongoExpressionEncodable
    {
        get
        {
            (nil, by: nil)
        }
        set(value)
        {
            if case (let dividend?, by: let divisor?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(dividend)
                    $0.append(divisor)
                }
            }
        }
    }

    @inlinable public
    subscript<Encodable, Array>(key:In) -> (_:Encodable?, in:Array?)
        where   Encodable:MongoExpressionEncodable,
                Array:MongoExpressionEncodable
    {
        get
        {
            (nil, in: nil)
        }
        set(value)
        {
            if case (let element?, in: let array?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(element)
                    $0.append(array)
                }
            }
        }
    }

    @inlinable public
    subscript<Base, Exponential>(key:Log) -> (base:Base?, of:Exponential?)
        where   Base:MongoExpressionEncodable,
                Exponential:MongoExpressionEncodable
    {
        get
        {
            (base: nil, of: nil)
        }
        set(value)
        {
            if case (base: let base?, of: let exponential?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(base)
                    $0.append(exponential)
                }
            }
        }
    }

    @inlinable public
    subscript<Base, Exponent>(key:Pow) -> (base:Base?, to:Exponent?)
        where   Base:MongoExpressionEncodable,
                Exponent:MongoExpressionEncodable
    {
        get
        {
            (base: nil, to: nil)
        }
        set(value)
        {
            if case (base: let base?, to: let exponent?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(base)
                    $0.append(exponent)
                }
            }
        }
    }

    @inlinable public
    subscript<Fraction>(key:Quantization) -> Fraction?
        where Fraction:MongoExpressionEncodable
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
        where   Fraction:MongoExpressionEncodable,
                Places:MongoExpressionEncodable
    {
        get
        {
            (nil, places: nil)
        }
        set(value)
        {
            if case (let fraction?, let places) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(fraction)
                    $0.push(places)
                }
            }
        }
    }

    @inlinable public
    subscript<Start, End, Step>(key:Range) -> (from:Start?, to:End?, by:Step?)
        where   Start:MongoExpressionEncodable,
                End:MongoExpressionEncodable,
                Step:MongoExpressionEncodable
    {
        get
        {
            (from: nil, to: nil, by: nil)
        }
        set(value)
        {
            if case (from: let start?, to: let end?, by: let step) = value
            {
                self.fields[pushing: key] = .init
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
        where   Start:MongoExpressionEncodable,
                End:MongoExpressionEncodable
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
        where   Array:MongoExpressionEncodable,
                Index:MongoExpressionEncodable,
                Distance:MongoExpressionEncodable
    {
        get
        {
            (nil, at: nil, distance: nil)
        }
        set(value)
        {
            if case (let array?, at: let index, distance: let distance?) = value
            {
                self.fields[pushing: key] = .init
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
        where   Array:MongoExpressionEncodable,
                Distance:MongoExpressionEncodable
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
        where   Minuend:MongoExpressionEncodable,
                Difference:MongoExpressionEncodable
    {
        get
        {
            (nil, minus: nil)
        }
        set(value)
        {
            if case (let minuend?, minus: let difference?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(minuend)
                    $0.append(difference)
                }
            }
        }
    }

    @inlinable public
    subscript<Count, Array>(key:Superlative) -> (_:Count?, of:Array?)
        where   Count:MongoExpressionEncodable,
                Array:MongoExpressionEncodable
    {
        get
        {
            (nil, of: nil)
        }
        set(value)
        {
            if case (let count?, of: let array?) = value
            {
                self.fields[pushing: key] = .init
                {
                    $0.append(count)
                    $0.append(array)
                }
            }
        }
    }

    @inlinable public
    subscript<Encodable>(key:Variadic) -> Encodable?
        where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
    @inlinable public
    subscript<T0, T1>(key:Variadic) -> (T0?, T1?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2>(key:Variadic) -> (T0?, T1?, T2?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable,
                T2:MongoExpressionEncodable
    {
        get
        {
            (nil, nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2, T3>(key:Variadic) -> (T0?, T1?, T2?, T3?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable,
                T2:MongoExpressionEncodable,
                T3:MongoExpressionEncodable
    {
        get
        {
            (nil, nil, nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
                $0.push(value.3)
            }
        }
    }
}
