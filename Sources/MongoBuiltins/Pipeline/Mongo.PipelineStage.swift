import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct PipelineStage:Sendable
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
extension Mongo.PipelineStage:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.PipelineStage:BSONEncodable
{
}
extension Mongo.PipelineStage:BSONDecodable
{
}

extension Mongo.PipelineStage
{
    @frozen public
    enum Bucket:String, Hashable, Sendable
    {
        case bucket = "$bucket"
    }
}
extension Mongo.PipelineStage
{
    @frozen public
    enum BucketAuto:String, Hashable, Sendable
    {
        case bucketAuto = "$bucketAuto"
    }
}
extension Mongo.PipelineStage
{
    @frozen public
    enum Group:String, Hashable, Sendable
    {
        case group = "$group"
    }
}
extension Mongo.PipelineStage
{
    @frozen public
    enum Match:String, Hashable, Sendable
    {
        case match = "$match"
    }
}
extension Mongo.PipelineStage
{
    @frozen public
    enum Project:String, Hashable, Sendable
    {
        case project = "$project"
    }
}
extension Mongo.PipelineStage
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort = "$sort"
    }
}
extension Mongo.PipelineStage
{
    @inlinable public
    subscript(key:Bucket) -> Mongo.BucketDocument?
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
    subscript(key:BucketAuto) -> Mongo.BucketAutoDocument?
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
    subscript(key:Group) -> Mongo.GroupDocument?
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
    subscript(key:Match) -> Mongo.PredicateDocument?
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
    subscript(key:Project) -> Mongo.ProjectionDocument?
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
    subscript(key:Sort) -> Mongo.SortDocument?
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
