import BSONDecoding
import BSONEncoding

extension MongoPipeline
{
    @frozen public
    struct Stage:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension MongoPipeline.Stage:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPipeline.Stage:BSONEncodable
{
}
extension MongoPipeline.Stage:BSONDecodable
{
}

extension MongoPipeline.Stage
{
    @frozen public
    enum Bucket:String, Hashable, Sendable
    {
        case bucket = "$bucket"
    }
}
extension MongoPipeline.Stage
{
    @frozen public
    enum BucketAuto:String, Hashable, Sendable
    {
        case bucketAuto = "$bucketAuto"
    }
}
extension MongoPipeline.Stage
{
    @frozen public
    enum Group:String, Hashable, Sendable
    {
        case group = "$group"
    }
}
extension MongoPipeline.Stage
{
    @frozen public
    enum Match:String, Hashable, Sendable
    {
        case match = "$match"
    }
}
extension MongoPipeline.Stage
{
    @frozen public
    enum Project:String, Hashable, Sendable
    {
        case project = "$project"
    }
}
extension MongoPipeline.Stage
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort = "$sort"
    }
}
extension MongoPipeline.Stage
{
    @inlinable public
    subscript(key:Bucket) -> MongoPipeline.Bucket?
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
    subscript(key:BucketAuto) -> MongoPipeline.BucketAuto?
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
    subscript(key:Group) -> MongoPipeline.Group?
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
    subscript(key:Match) -> MongoPredicate?
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
    subscript(key:Project) -> MongoProjection?
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
    subscript(key:Sort) -> MongoSortOrdering?
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
