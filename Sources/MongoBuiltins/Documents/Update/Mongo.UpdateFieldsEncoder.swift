import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct UpdateFieldsEncoder<Operator>:Sendable
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
extension Mongo.UpdateFieldsEncoder:BSON.Encoder
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

extension Mongo.UpdateFieldsEncoder where Operator:Mongo.UpdateValueOperator
{
    @inlinable public
    subscript<Encodable>(path:Mongo.AnyKeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Arithmetic>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Int?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Double?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Assignment>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: path][as: Mongo.ExpressionEncoder.self]) }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Bit>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> (operator:Mongo.UpdateBitwiseOperator, int32:Int32)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                {
                    $0[name] = operand
                } (&self.bson[with: path][
                    as: BSON.DocumentEncoder<Mongo.UpdateBitwiseOperator>.self])
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> (operator:Mongo.UpdateBitwiseOperator, int64:Int64)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                {
                    $0[name] = operand
                } (&self.bson[with: path][
                    as: BSON.DocumentEncoder<Mongo.UpdateBitwiseOperator>.self])
            }
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.CurrentDate>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> BSON.Millisecond.Type?
    {
        get
        {
            nil
        }
        set(value)
        {
            {
                $0["$type"] = "date"
            } (&self.bson[with: path][as: BSON.DocumentEncoder<BSON.Key>.self])
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Pop>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.UpdatePosition?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Pull>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.PredicateOperatorEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: path][as: Mongo.PredicateOperatorEncoder.self]) }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.ArrayUnion>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.UpdateArrayEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: path][as: Mongo.UpdateArrayEncoder.self]) }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Rename>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.AnyKeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.stem.encode(to: &self.bson[with: path.stem])
        }
    }
}
extension Mongo.UpdateFieldsEncoder<Mongo.UpdateEncoder.Unset>
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Void?
    {
        get
        {
            nil
        }
        set(value)
        {
            (nil as Never?).encode(to: &self.bson[with: path.stem])
        }
    }
}
