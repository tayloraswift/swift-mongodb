import BSONEncoding
import MongoExpressions

extension Mongo
{
    @frozen public
    struct PipelineStage:MongoDocumentDSL, Sendable
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
extension Mongo.PipelineStage
{
    @inlinable public
    subscript(key:Out) -> Mongo.Collection?
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
    subscript(key:Out) -> Mongo.Namespaced<Mongo.Collection>?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value?.document)
        }
    }
    @inlinable public
    subscript(key:Merge) -> Mongo.MergeDocument?
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
        }
    }

    @inlinable public
    subscript(key:Count) -> String?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:ChangeStream) -> Never?
    {
        nil
    }

    @inlinable public
    subscript(key:CollectionStats) -> Mongo.CollectionStatsDocument?
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
    subscript(key:CurrentOperation) -> Mongo.CurrentOperationDocument?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:Densify) -> Never?
    {
        nil
    }

    @inlinable public
    subscript<Array>(key:Documents) -> Array? where Array:BSONEncodable
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
    subscript(key:Facet) -> Mongo.FacetDocument?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:Fill) -> Never?
    {
        nil
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:GeoNear) -> Never?
    {
        nil
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:GraphLookup) -> Never?
    {
        nil
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
            self.bson.push(key, value)
        }
    }

    @inlinable public
    subscript(key:IndexStats) -> [String: Never]?
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
    subscript(key:Limit) -> Int?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:ListLocalSessions) -> Never?
    {
        nil
    }
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:ListSessions) -> Never?
    {
        nil
    }

    @inlinable public
    subscript(key:Lookup) -> Mongo.LookupDocument?
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
    subscript(key:Match) -> Mongo.PredicateDocument?
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
    subscript(key:PlanCacheStats) -> [String: Never]?
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
    subscript(key:Project) -> Mongo.ProjectionDocument?
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
    subscript<RedactMode>(key:Redact) -> RedactMode? where RedactMode:BSONEncodable
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
    subscript<Document>(key:ReplaceWith) -> Document? where Document:BSONEncodable
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
    subscript(key:Sample) -> Mongo.SampleDocument?
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
    subscript(key:Set) -> Mongo.SetDocument?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:SetWindowFields) -> Never?
    {
        nil
    }

    @inlinable public
    subscript(key:ShardedDataDistribution) -> [String: Never]?
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
    subscript(key:Skip) -> Int?
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
    subscript(key:Sort) -> Mongo.SortDocument?
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
    subscript<GroupKey>(key:SortByCount) -> GroupKey? where GroupKey:BSONEncodable
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
    subscript(key:UnionWith) -> Mongo.Collection?
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
    subscript(key:UnionWith) -> Mongo.UnionWithDocument?
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
    subscript(key:Unset) -> String?
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
    subscript(key:Unset) -> [String]?
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
    subscript<FieldPath>(key:Unwind) -> FieldPath?
        where FieldPath:MongoFieldPathEncodable
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
    subscript(key:Unwind) -> Mongo.UnwindDocument?
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
