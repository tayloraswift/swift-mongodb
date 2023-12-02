import BSON

extension Mongo
{
    @frozen public
    struct ProjectionOperator:MongoDocumentDSL, Sendable
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson[key]
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
