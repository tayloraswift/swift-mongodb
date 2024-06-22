import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct PipelineEncoder:Sendable
    {
        @usableFromInline
        var list:BSON.ListEncoder

        @inlinable internal
        init(list:BSON.ListEncoder)
        {
            self.list = list
        }
    }
}
extension Mongo.PipelineEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(list: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.list.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .list }
}
extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Out) -> Mongo.Collection?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.Collection
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Out.self)
            {
                $0[.out] = value
            }
        }
    }

    @inlinable public
    subscript(stage key:Mongo.Pipeline.Out) -> Mongo.Namespaced<Mongo.Collection>?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.Namespaced<Mongo.Collection>
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Out.self)
            {
                $0[.out] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Merge) -> Mongo.MergeDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.MergeDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Merge.self)
            {
                $0[.merge] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Bucket) -> Mongo.BucketDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.BucketDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Bucket.self)
            {
                $0[.bucket] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.BucketAuto) -> Mongo.BucketAutoDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.BucketAutoDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.BucketAuto.self)
            {
                $0[.bucketAuto] = value
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Count) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.AnyKeyPath
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Count.self)
            {
                $0[.count] = value.stem
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum ChangeStream:String, Sendable
    {
        case changeStream = "$changeStream"
    }

    @inlinable public
    subscript(stage key:ChangeStream,
        yield:(inout Mongo.ChangeStreamEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(ChangeStream.self)
            {
                yield(&$0[with: key][as: Mongo.ChangeStreamEncoder.self])
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.CollectionStats) -> Mongo.CollectionStatsDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.CollectionStatsDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.CollectionStats.self)
            {
                $0[.collectionStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.CurrentOperation) -> Mongo.CurrentOperationDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.CurrentOperationDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.CurrentOperation.self)
            {
                $0[.currentOperation] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Densify) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript<Array>(stage key:Mongo.Pipeline.Documents) -> Array? where Array:BSONEncodable
    {
        get { nil }
        set (value)
        {
            guard
            let value:Array
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Documents.self)
            {
                $0[.documents] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Facet) -> Mongo.FacetDocument<Mongo.AnyKeyPath>?
    {
        nil
    }

    @inlinable public
    subscript<FacetKey>(stage facet:Mongo.Pipeline.Facet,
        using key:FacetKey.Type = FacetKey.self,
        yield:(inout Mongo.FacetEncoder<FacetKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(Mongo.Pipeline.Facet.self)
            {
                yield(&$0[with: facet][as: Mongo.FacetEncoder<FacetKey>.self])
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Fill) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.GeoNear) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.GraphLookup) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Group) -> Mongo.GroupDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.GroupDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Group.self)
            {
                $0[.group] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.IndexStats) -> [String: Never]?
    {
        get { nil }
        set (value)
        {
            guard
            let value:[String: Never]
            else
            {
                return
            }

            self.list(Mongo.Pipeline.IndexStats.self)
            {
                $0[.indexStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Limit) -> Int?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Int
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Limit.self)
            {
                $0[.limit] = value
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ListLocalSessions) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ListSessions) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Lookup) -> Mongo.LookupDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.LookupDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Lookup.self)
            {
                $0[.lookup] = value
            }
        }
    }

    @inlinable public
    subscript(stage lookup:Mongo.Pipeline.Lookup,
        yield:(inout Mongo.LookupEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(Mongo.Pipeline.Lookup.self)
            {
                yield(&$0[with: lookup][as: Mongo.LookupEncoder.self])
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Match) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.PredicateDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Match.self)
            {
                $0[.match] = value
            }
        }
    }

    @inlinable public
    subscript(stage match:Mongo.Pipeline.Match,
        yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(Mongo.Pipeline.Match.self)
            {
                yield(&$0[with: match][as: Mongo.PredicateEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Predicate>(stage match:Mongo.Pipeline.Match) -> Predicate?
        where Predicate:Mongo.PredicateEncodable
    {
        get { nil }
        set (value)
        {
            if  let value:Predicate
            {
                self[stage: match, value.encode(to:)]
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.PlanCacheStats) -> [String: Never]?
    {
        get { nil }
        set (value)
        {
            guard
            let value:[String: Never]
            else
            {
                return
            }

            self.list(Mongo.Pipeline.PlanCacheStats.self)
            {
                $0[.planCacheStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Project) -> Mongo.ProjectionDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.ProjectionDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Project.self)
            {
                $0[.project] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript<RedactMode>(stage key:Mongo.Pipeline.Redact) -> RedactMode?
        where RedactMode:BSONEncodable
    {
        get { nil }
        set (value)
        {
            guard
            let value:RedactMode
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Redact.self)
            {
                $0[.redact] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript<Document>(stage key:Mongo.Pipeline.ReplaceWith) -> Document?
        where Document:BSONEncodable
    {
        get { nil }
        set (value)
        {
            guard
            let value:Document
            else
            {
                return
            }

            self.list(Mongo.Pipeline.ReplaceWith.self)
            {
                $0[.replaceWith] = value
            }
        }
    }

    @inlinable public
    subscript(stage key:Mongo.Pipeline.ReplaceWith) -> Mongo.SetDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.SetDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.ReplaceWith.self)
            {
                $0[.replaceWith] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Sample) -> Mongo.SampleDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.SampleDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Sample.self)
            {
                $0[.sample] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Set) -> Mongo.SetDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.SetDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Set.self)
            {
                $0[.set] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.SetWindowFields) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ShardedDataDistribution) -> [String: Never]?
    {
        get { nil }
        set (value)
        {
            guard
            let value:[String: Never]
            else
            {
                return
            }

            self.list(Mongo.Pipeline.ShardedDataDistribution.self)
            {
                $0[.shardedDataDistribution] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Skip) -> Int?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Int
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Skip.self)
            {
                $0[.skip] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Sort) -> Mongo.SortDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.SortDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Sort.self)
            {
                $0[.sort] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript<GroupKey>(stage key:Mongo.Pipeline.SortByCount) -> GroupKey?
        where GroupKey:BSONEncodable
    {
        get { nil }
        set (value)
        {
            guard
            let value:GroupKey
            else
            {
                return
            }

            self.list(Mongo.Pipeline.SortByCount.self)
            {
                $0[.sortByCount] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.UnionWith) -> Mongo.Collection?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.Collection
            else
            {
                return
            }

            self.list(Mongo.Pipeline.UnionWith.self)
            {
                $0[.unionWith] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.UnionWith) -> Mongo.UnionWithDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.UnionWithDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.UnionWith.self)
            {
                $0[.unionWith] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Unset) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.AnyKeyPath
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Unset.self)
            {
                $0[.unset] = value.stem
            }
        }
    }

    /// Does nothing if the assigned array is empty.
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Unset) -> [Mongo.AnyKeyPath]
    {
        get { [ ] }
        set (value)
        {
            if  value.isEmpty
            {
                return
            }

            self.list(Mongo.Pipeline.Unset.self)
            {
                $0[.unset]
                {
                    for path:Mongo.AnyKeyPath in value
                    {
                        $0.append(path.stem)
                    }
                }
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Unwind) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.AnyKeyPath
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Unwind.self)
            {
                // includes the `$` prefix!
                $0[.unwind] = value
            }
        }
    }

    @inlinable public
    subscript(stage key:Mongo.Pipeline.Unwind) -> Mongo.UnwindDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.UnwindDocument
            else
            {
                return
            }

            self.list(Mongo.Pipeline.Unwind.self)
            {
                $0[.unwind] = value
            }
        }
    }
}
