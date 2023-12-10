import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct UpdateFields<Operator>:MongoDocumentDSL, Sendable
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Arithmetic>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Int?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Double?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Bit>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> (operator:Mongo.UpdateBitwiseOperator, int32:Int32)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                self.bson[path.stem]
                {
                    $0[name] = operand
                }
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> (operator:Mongo.UpdateBitwiseOperator, int64:Int64)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                self.bson[path.stem]
                {
                    $0[name] = operand
                }
            }
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.CurrentDate>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> BSON.Millisecond.Type?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[path.stem]
            {
                $0["$type"] = "date"
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> UInt64.Type?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[path.stem]
            {
                $0["$type"] = "timestamp"
            }
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Pop>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.UpdatePosition?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Pull>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.PredicateOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
    @inlinable public
    subscript<Encodable>(path:Mongo.KeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Reduction>
{
    @inlinable public
    subscript<Encodable>(path:Mongo.KeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Rename>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.KeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value?.stem)
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Unset>
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Void?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.append(path.stem, nil as Never?)
        }
    }
}
