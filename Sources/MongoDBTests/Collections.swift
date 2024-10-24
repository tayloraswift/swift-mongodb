import MongoDB
import Testing

@Suite
struct Collections:Mongo.TestBattery
{
    let database:Mongo.Database = "Collections"

    @Test(arguments: [.single, .replicated] as [any Mongo.TestConfiguration])
    func collections(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        var collections:[Mongo.Collection] = (0 ..< 32).map { .init($0.description) }
        let session:Mongo.Session = try await .init(from: pool)

        for collection:Mongo.Collection in collections
        {
            try await session.run(
                command: Mongo.Create<Mongo.Collection>.init(collection),
                against: self.database)
        }

        try await session.run(
            command: Mongo.ListCollections<Mongo.CollectionBinding>.init(stride: 10),
            against: self.database)
        {
            var collections:Set<Mongo.Collection> = .init(collections)
            for try await batch:[Mongo.CollectionBinding] in $0
            {
                #expect(batch.count <= 10)
                for binding:Mongo.CollectionBinding in batch
                {
                    #expect(collections.remove(binding.collection) != nil)
                    #expect(binding.type == .collection)
                }
            }
            #expect(collections == [])
        }
        try await session.run(
            command: Mongo.ListCollections<Mongo.CollectionMetadata>.init(stride: 10),
            against: self.database)
        {
            var collections:Set<Mongo.Collection> = .init(collections)
            for try await batch:[Mongo.CollectionMetadata] in $0
            {
                #expect(batch.count <= 10)
                for metadata:Mongo.CollectionMetadata in batch
                {
                    #expect(collections.remove(metadata.collection) != nil)
                    #expect(metadata.type == .collection)
                }
            }
            #expect(collections == [])
        }

        let target:Mongo.Namespaced<Mongo.Collection> = self.database | "Renamed"
        try await session.run(
            command: Mongo.RenameCollection.init(self.database | collections[0], to: target),
            against: .admin)

        collections[0] = target.collection

        for collection:Mongo.Collection in collections
        {
            try await session.run(command: Mongo.Drop.init(collection), against: self.database)
        }
    }
}
