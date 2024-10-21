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
    @frozen public
    enum Out:String, Hashable, Sendable
    {
        case out = "$out"
    }

    @inlinable public
    subscript(stage out:Out) -> Mongo.Collection?
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

            self.list(Out.self)
            {
                $0[out] = value
            }
        }
    }

    @inlinable public
    subscript(stage out:Out) -> Mongo.Namespaced<Mongo.Collection>?
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

            self.list(Out.self)
            {
                $0[out] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Merge:String, Hashable, Sendable
    {
        case merge = "$merge"
    }

    @inlinable public
    subscript(stage merge:Merge) -> Mongo.MergeDocument?
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

            self.list(Merge.self)
            {
                $0[merge] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Bucket:String, Hashable, Sendable
    {
        case bucket = "$bucket"
    }

    @inlinable public
    subscript(stage bucket:Bucket, yield:(inout Mongo.BucketEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(Bucket.self)
            {
                yield(&$0[with: bucket][as: Mongo.BucketEncoder.self])
            }
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Bucket) -> Mongo.BucketDocument?
    {
        get { nil }
        set (value) {}
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum BucketAuto:String, Hashable, Sendable
    {
        case bucketAuto = "$bucketAuto"
    }

    @inlinable public
    subscript(stage bucketAuto:BucketAuto, yield:(inout Mongo.BucketAutoEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(BucketAuto.self)
            {
                yield(&$0[with: bucketAuto][as: Mongo.BucketAutoEncoder.self])
            }
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:BucketAuto) -> Mongo.BucketAutoDocument?
    {
        get { nil }
        set (value) {}
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "$count"
    }

    @inlinable public
    subscript(stage count:Count) -> Mongo.AnyKeyPath?
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

            self.list(Count.self)
            {
                $0[count] = value.stem
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
    subscript(stage changeStream:ChangeStream,
        yield:(inout Mongo.ChangeStreamEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(ChangeStream.self)
            {
                yield(&$0[with: changeStream][as: Mongo.ChangeStreamEncoder.self])
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum CollectionStats:String, Hashable, Sendable
    {
        case collectionStats = "$collStats"

        @available(*, unavailable, renamed: "collectionStats")
        public
        static var collStats:Self { .collectionStats }
    }

    @inlinable public
    subscript(stage collStats:CollectionStats) -> Mongo.CollectionStatsDocument?
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

            self.list(CollectionStats.self)
            {
                $0[collStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum CurrentOperation:String, Hashable, Sendable
    {
        case currentOperation = "$currentOp"

        @available(*, unavailable, renamed: "currentOperation")
        public
        static var currentOp:Self { .currentOperation }
    }

    @inlinable public
    subscript(stage currentOp:CurrentOperation) -> Mongo.CurrentOperationDocument?
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

            self.list(CurrentOperation.self)
            {
                $0[currentOp] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Densify:String, Hashable, Sendable
    {
        case densify = "$densify"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage densify:Densify) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Documents:String, Hashable, Sendable
    {
        case documents = "$documents"
    }

    @inlinable public
    subscript<Array>(stage documents:Documents) -> Array? where Array:BSONEncodable
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

            self.list(Documents.self)
            {
                $0[documents] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Facet:String, Hashable, Sendable
    {
        case facet = "$facet"
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Facet) -> Mongo.FacetDocument<Mongo.AnyKeyPath>?
    {
        nil
    }

    @inlinable public
    subscript<FacetKey>(stage facet:Facet,
        using key:FacetKey.Type = FacetKey.self,
        yield:(inout Mongo.FacetEncoder<FacetKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(Facet.self)
            {
                yield(&$0[with: facet][as: Mongo.FacetEncoder<FacetKey>.self])
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum Fill:String, Hashable, Sendable
    {
        case fill = "$fill"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage fill:Fill) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum GeoNear:String, Hashable, Sendable
    {
        case geoNear = "$geoNear"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage geoNear:GeoNear) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum GraphLookup:String, Hashable, Sendable
    {
        case graphLookup = "$graphLookup"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage graphLookup:GraphLookup) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Group:String, Hashable, Sendable
    {
        case group = "$group"
    }

    @inlinable public
    subscript(stage group:Group) -> Mongo.GroupDocument?
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

            self.list(Group.self)
            {
                $0[group] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum IndexStats:String, Hashable, Sendable
    {
        case indexStats = "$indexStats"
    }

    @inlinable public
    subscript(stage indexStats:IndexStats) -> [String: Never]?
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

            self.list(IndexStats.self)
            {
                $0[indexStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Limit:String, Hashable, Sendable
    {
        case limit = "$limit"
    }

    @inlinable public
    subscript(stage limit:Limit) -> Int?
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

            self.list(Limit.self)
            {
                $0[limit] = value
            }
        }
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum ListLocalSessions:String, Hashable, Sendable
    {
        case listLocalSessions = "$listLocalSessions"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage listLocalSessions:ListLocalSessions) -> Never?
    {
        nil
    }
}
extension Mongo.PipelineEncoder
{
    @frozen public
    enum ListSessions:String, Hashable, Sendable
    {
        case listSessions = "$listSessions"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage listSessions:ListSessions) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Lookup:String, Hashable, Sendable
    {
        case lookup = "$lookup"
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage lookup:Lookup) -> Mongo.LookupDocument?
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

            self.list(Lookup.self)
            {
                $0[lookup] = value
            }
        }
    }

    @inlinable public
    subscript(stage lookup:Lookup, yield:(inout Mongo.LookupEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(Lookup.self)
            {
                yield(&$0[with: lookup][as: Mongo.LookupEncoder.self])
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Match:String, Hashable, Sendable
    {
        case match = "$match"
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Match) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value) {}
    }

    @inlinable public
    subscript(stage match:Match, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(Match.self)
            {
                yield(&$0[with: match][as: Mongo.PredicateEncoder.self])
            }
        }
    }

    @inlinable public
    subscript<Predicate>(stage match:Match) -> Predicate?
        where Predicate:Mongo.PredicateEncodable
    {
        get { nil }
        set (value) { value.map { self[stage: match, $0.encode(to:)] } }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum PlanCacheStats:String, Hashable, Sendable
    {
        case planCacheStats = "$planCacheStats"
    }

    @inlinable public
    subscript(stage planCacheStats:PlanCacheStats) -> [String: Never]?
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

            self.list(PlanCacheStats.self)
            {
                $0[.planCacheStats] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Project:String, Hashable, Sendable
    {
        case project = "$project"
    }

    @inlinable public
    subscript<CodingKey>(stage project:Project,
        using _:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.ProjectionEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(Project.self)
            {
                yield(&$0[with: project][as: Mongo.ProjectionEncoder<CodingKey>.self])
            }
        }
    }

    @inlinable public
    subscript<ProjectionDocument>(stage project:Project) -> ProjectionDocument?
        where ProjectionDocument:Mongo.ProjectionEncodable
    {
        get { nil }
        set (value) { value.map { self[stage: project, $0.encode(to:)] } }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Project) -> Mongo.ProjectionDocument<Mongo.AnyKeyPath>?
    {
        get { nil }
        set {     }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Redact:String, Hashable, Sendable
    {
        case redact = "$redact"
    }

    @inlinable public
    subscript<RedactMode>(stage redact:Redact) -> RedactMode?
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

            self.list(Redact.self)
            {
                $0[redact] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum ReplaceWith:String, Hashable, Sendable
    {
        case replaceWith = "$replaceWith"

        @available(*, unavailable, message: "Use the 'replaceWith' stage instead.")
        public
        static var replaceRoot:Self { fatalError() }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:ReplaceWith) -> Mongo.SetDocument<Mongo.AnyKeyPath>?
    {
        nil
    }

    /// Replaces the root document with a new document computed by an ``Expression``, usually a
    /// ``Mongo.ExpressionEncoder.Variadic/mergeObjects`` expression.
    @inlinable public
    subscript(stage replaceWith:ReplaceWith,
        yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.list(ReplaceWith.self)
            {
                yield(&$0[with: replaceWith][as: Mongo.ExpressionEncoder.self])
            }
        }
    }

    /// Replaces the root document with a new document using the specified schema.
    @inlinable public
    subscript<CodingKey>(stage replaceWith:ReplaceWith,
        using key:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SetEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(ReplaceWith.self)
            {
                yield(&$0[with: replaceWith][as: Mongo.SetEncoder<CodingKey>.self])
            }
        }
    }

    @inlinable public
    subscript<Document>(stage replaceWith:ReplaceWith) -> Document?
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

            self.list(ReplaceWith.self)
            {
                $0[replaceWith] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Sample:String, Hashable, Sendable
    {
        case sample = "$sample"
    }

    @inlinable public
    subscript(stage sample:Sample) -> Mongo.SampleDocument?
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

            self.list(Sample.self)
            {
                $0[sample] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Set:String, Hashable, Sendable
    {
        case set = "$set"

        @available(*, unavailable, renamed: "set")
        public
        static var addFields:Self { .set }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Set) -> Mongo.SetDocument<Mongo.AnyKeyPath>?
    {
        nil
    }

    @inlinable public
    subscript<CodingKey>(stage set:Set,
        using key:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SetEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(Set.self)
            {
                yield(&$0[with: set][as: Mongo.SetEncoder<CodingKey>.self])
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum SetWindowFields:String, Hashable, Sendable
    {
        case setWindowFields = "$setWindowFields"
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(stage setWindowFields:SetWindowFields) -> Never?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum ShardedDataDistribution:String, Hashable, Sendable
    {
        case shardedDataDistribution = "$shardedDataDistribution"
    }

    @inlinable public
    subscript(stage shardedDataDistribution:ShardedDataDistribution) -> [String: Never]?
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

            self.list(ShardedDataDistribution.self)
            {
                $0[shardedDataDistribution] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Skip:String, Hashable, Sendable
    {
        case skip = "$skip"
    }

    @inlinable public
    subscript(stage skip:Skip) -> Int?
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

            self.list(Skip.self)
            {
                $0[skip] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort = "$sort"
    }

    @inlinable public
    subscript<CodingKey>(stage sort:Sort,
        using _:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SortEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            self.list(Sort.self)
            {
                yield(&$0[with: sort][as: Mongo.SortEncoder<CodingKey>.self])
            }
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(stage key:Sort) -> Mongo.SortDocument<Mongo.AnyKeyPath>?
    {
        nil
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum SortByCount:String, Hashable, Sendable
    {
        case sortByCount = "$sortByCount"
    }

    @inlinable public
    subscript<GroupKey>(stage sortByCount:SortByCount) -> GroupKey?
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

            self.list(SortByCount.self)
            {
                $0[sortByCount] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum UnionWith:String, Hashable, Sendable
    {
        case unionWith = "$unionWith"
    }

    @inlinable public
    subscript(stage unionWith:UnionWith) -> Mongo.Collection?
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

            self.list(UnionWith.self)
            {
                $0[unionWith] = value
            }
        }
    }

    @inlinable public
    subscript(stage unionWith:UnionWith) -> Mongo.UnionWithDocument?
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

            self.list(UnionWith.self)
            {
                $0[unionWith] = value
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Unset:String, Hashable, Sendable
    {
        case unset = "$unset"
    }

    @inlinable public
    subscript(stage unset:Unset) -> Mongo.AnyKeyPath?
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

            self.list(Unset.self)
            {
                $0[unset] = value.stem
            }
        }
    }

    /// Does nothing if the assigned array is empty.
    @inlinable public
    subscript(stage unset:Unset) -> [Mongo.AnyKeyPath]
    {
        get { [ ] }
        set (value)
        {
            if  value.isEmpty
            {
                return
            }

            self.list(Unset.self)
            {
                $0[unset](Int.self)
                {
                    for path:Mongo.AnyKeyPath in value
                    {
                        $0[+] = path.stem
                    }
                }
            }
        }
    }
}

extension Mongo.PipelineEncoder
{
    @frozen public
    enum Unwind:String, Hashable, Sendable
    {
        case unwind = "$unwind"
    }

    @inlinable public
    subscript(stage unwind:Unwind) -> Mongo.AnyKeyPath?
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

            self.list(Unwind.self)
            {
                // includes the `$` prefix!
                $0[unwind] = value
            }
        }
    }

    @inlinable public
    subscript(stage unwind:Unwind) -> Mongo.UnwindDocument?
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

            self.list(Unwind.self)
            {
                $0[unwind] = value
            }
        }
    }
}
