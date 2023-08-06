import MongoQL

extension Mongo
{
    @frozen public
    struct CollectionView:Sendable
    {
        public
        let collection:Collection
        public
        let pipeline:Pipeline

        public
        init(on collection:Collection, pipeline:Pipeline)
        {
            self.collection = collection
            self.pipeline = pipeline
        }
    }
}
extension Mongo.CollectionView
{
    @inlinable public
    init(on collection:Mongo.Collection,
        pipeline populate:(inout Mongo.Pipeline) throws -> ()) rethrows
    {
        self.init(on: collection, pipeline: try .init(with: populate))
    }
}
