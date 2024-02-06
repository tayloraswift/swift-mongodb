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
    var type:BSON.AnyType { .list }
}
extension Mongo.PipelineEncoder
{
    /// This is a legacy source compatibility aid that does nothing and will be deprecated soon.
    @available(*, deprecated, message: "use subscripts instead")
    @inlinable public mutating
    func stage(_ populate:(inout Self) throws -> ()) rethrows
    {
        try populate(&self)
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Out) -> Mongo.Collection?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Out.self)
            {
                $0[.out] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Out) -> Mongo.Namespaced<Mongo.Collection>?
    {
        get { nil }
        set (value) { self[stage: key] = value }
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

            self.list.append(using: Mongo.Pipeline.Out.self)
            {
                $0[.out] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Merge) -> Mongo.MergeDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Merge.self)
            {
                $0[.merge] = value
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Bucket) -> Mongo.BucketDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Bucket.self)
            {
                $0[.bucket] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.BucketAuto) -> Mongo.BucketAutoDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.BucketAuto.self)
            {
                $0[.bucketAuto] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Count) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Count.self)
            {
                $0[.count] = value.stem
            }
        }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ChangeStream) -> Never?
    {
        nil
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.CollectionStats) -> Mongo.CollectionStatsDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.CollectionStats.self)
            {
                $0[.collectionStats] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.CurrentOperation) -> Mongo.CurrentOperationDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.CurrentOperation.self)
            {
                $0[.currentOperation] = value
            }
        }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Densify) -> Never?
    {
        nil
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript<Array>(key:Mongo.Pipeline.Documents) -> Array? where Array:BSONEncodable
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Documents.self)
            {
                $0[.documents] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Facet) -> Mongo.FacetDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

    @inlinable public
    subscript(stage key:Mongo.Pipeline.Facet) -> Mongo.FacetDocument?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Mongo.FacetDocument
            else
            {
                return
            }

            self.list.append(using: Mongo.Pipeline.Facet.self)
            {
                $0[.facet] = value
            }
        }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.Fill) -> Never?
    {
        nil
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.GeoNear) -> Never?
    {
        nil
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.GraphLookup) -> Never?
    {
        nil
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Group) -> Mongo.GroupDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Group.self)
            {
                $0[.group] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.IndexStats) -> [String: Never]?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.IndexStats.self)
            {
                $0[.indexStats] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Limit) -> Int?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Limit.self)
            {
                $0[.limit] = value
            }
        }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ListLocalSessions) -> Never?
    {
        nil
    }
    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.ListSessions) -> Never?
    {
        nil
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Lookup) -> Mongo.LookupDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Lookup.self)
            {
                $0[.lookup] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Match) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Match.self)
            {
                $0[.match] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.PlanCacheStats) -> [String: Never]?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.PlanCacheStats.self)
            {
                $0[.planCacheStats] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Project) -> Mongo.ProjectionDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Project.self)
            {
                $0[.project] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript<RedactMode>(key:Mongo.Pipeline.Redact) -> RedactMode?
        where RedactMode:BSONEncodable
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Redact.self)
            {
                $0[.redact] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript<Document>(key:Mongo.Pipeline.ReplaceWith) -> Document?
        where Document:BSONEncodable
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.ReplaceWith.self)
            {
                $0[.replaceWith] = value
            }
        }
    }

    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.ReplaceWith) -> Mongo.SetDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
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

            self.list.append(using: Mongo.Pipeline.ReplaceWith.self)
            {
                $0[.replaceWith] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Sample) -> Mongo.SampleDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Sample.self)
            {
                $0[.sample] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Set) -> Mongo.SetDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Set.self)
            {
                $0[.set] = value
            }
        }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage key:Mongo.Pipeline.SetWindowFields) -> Never?
    {
        nil
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.ShardedDataDistribution) -> [String: Never]?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.ShardedDataDistribution.self)
            {
                $0[.shardedDataDistribution] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Skip) -> Int?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Skip.self)
            {
                $0[.skip] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Sort) -> Mongo.SortDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Sort.self)
            {
                $0[.sort] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript<GroupKey>(key:Mongo.Pipeline.SortByCount) -> GroupKey?
        where GroupKey:BSONEncodable
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.SortByCount.self)
            {
                $0[.sortByCount] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.UnionWith) -> Mongo.Collection?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.UnionWith.self)
            {
                $0[.unionWith] = value
            }
        }
    }

    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.UnionWith) -> Mongo.UnionWithDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.UnionWith.self)
            {
                $0[.unionWith] = value
            }
        }
    }


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Unset) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Unset.self)
            {
                $0[.unset] = value.stem
            }
        }
    }

    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Unset) -> [Mongo.AnyKeyPath]
    {
        get { [ ] }
        set (value) { self[stage: key] = value }
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

            self.list.append(using: Mongo.Pipeline.Unset.self)
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


    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Unwind) -> Mongo.AnyKeyPath?
    {
        get { nil }
        set (value) { self[stage: key] = value }
    }

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

            self.list.append(using: Mongo.Pipeline.Unwind.self)
            {
                // includes the `$` prefix!
                $0[.unwind] = value
            }
        }
    }

    @available(*, deprecated, renamed: "subscript(stage:)")
    @inlinable public
    subscript(key:Mongo.Pipeline.Unwind) -> Mongo.UnwindDocument?
    {
        get { nil }
        set (value) { self[stage: key] = value }
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

            self.list.append(using: Mongo.Pipeline.Unwind.self)
            {
                $0[.unwind] = value
            }
        }
    }
}
