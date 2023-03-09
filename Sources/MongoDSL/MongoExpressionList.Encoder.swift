import BSONEncoding

extension MongoExpressionList
{
    @frozen public
    struct Encoder
    {
        @usableFromInline internal
        var bson:BSON.ListEncoder

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.bson = .init(output: output)
        }
    }
}
extension MongoExpressionList.Encoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .list }

    @inlinable public
    var output:BSON.Output<[UInt8]>
    {
        self.bson.output
    }
}
extension MongoExpressionList.Encoder
{
    @inlinable internal mutating
    func append(with encode:(inout BSON.Field) -> ())
    {
        self.bson.append(with: encode)
    }

    @inlinable public mutating
    func append(_ element:some MongoExpressionEncodable)
    {
        self.bson.append(element)
    }
    @inlinable public mutating
    func push(_ element:(some MongoExpressionEncodable)?)
    {
        self.bson.push(element)
    }
    
    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some MongoExpressionEncodable)
    {
        self.append(element)
    }
}
extension MongoExpressionList.Encoder
{
    @inlinable public mutating
    func append(with encode:(inout MongoExpression) -> ())
    {
        self.append(MongoExpression.init(with: encode))
    }
    @inlinable public mutating
    func append(with encode:(inout Self) -> ())
    {
        self.append { $0.encode(with: encode) }
    }
}
