import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct ProjectionOperator:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.ProjectionOperator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.ProjectionOperator:BSONEncodable
{
}
extension Mongo.ProjectionOperator:BSONDecodable
{
}

extension Mongo.ProjectionOperator
{
    @inlinable public
    subscript(key:First) -> Mongo.PredicateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
}
extension Mongo.ProjectionOperator
{
    @inlinable public
    subscript(key:Meta) -> Metadata?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
}
extension Mongo.ProjectionOperator
{
    @inlinable public
    subscript<Distance>(key:Slice) -> Distance?
        where Distance:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript<Index, Count>(key:Slice) -> (at:Index?, count:Count?)
        where Index:BSONEncodable, Count:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            guard let count:Count = value.count
            else
            {
                return
            }
            self.document[key]
            {
                if let index:Index = value.at
                {
                    $0.append(index)
                }
                $0.append(count)
            }
        }
    }
}
