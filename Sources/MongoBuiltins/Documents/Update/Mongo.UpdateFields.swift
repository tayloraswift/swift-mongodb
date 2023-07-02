import BSONEncoding
import MongoExpressions

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
    subscript(key:BSON.Key) -> Int?
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
    subscript(key:BSON.Key) -> Double?
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Bit>
{
    @inlinable public
    subscript(key:BSON.Key) -> (operator:Mongo.UpdateBitwiseOperator, int32:Int32)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                self.bson[key]
                {
                    $0[name] = operand
                }
            }
        }
    }
    @inlinable public
    subscript(key:BSON.Key) -> (operator:Mongo.UpdateBitwiseOperator, int64:Int64)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case let (name, operand)? = value
            {
                self.bson[key]
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
    subscript(key:BSON.Key) -> BSON.Millisecond.Type?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[key]
            {
                $0["$type"] = "date"
            }
        }
    }
    @inlinable public
    subscript(key:BSON.Key) -> UInt64.Type?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[key]
            {
                $0["$type"] = "timestamp"
            }
        }
    }
}
extension Mongo.UpdateFields<Mongo.UpdateDocument.Pop>
{
    @inlinable public
    subscript(key:BSON.Key) -> Mongo.UpdatePosition?
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Pull>
{
    @inlinable public
    subscript(key:BSON.Key) -> Mongo.PredicateOperator?
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
    subscript<Encodable>(key:BSON.Key) -> Encodable? where Encodable:BSONEncodable
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Reduction>
{
    @inlinable public
    subscript<Encodable>(key:BSON.Key) -> Encodable? where Encodable:BSONEncodable
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Rename>
{
    @inlinable public
    subscript(key:BSON.Key) -> String?
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
extension Mongo.UpdateFields<Mongo.UpdateDocument.Unset>
{
    @inlinable public
    subscript(key:BSON.Key) -> Void?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.append(key, nil as Never?)
        }
    }
}
