extension Mongo.Session
{
    @_spi(session) public
    func stats(
        collection:Mongo.Namespaced<Mongo.Collection>) async throws -> Mongo.CollectionStats?
    {
        let command:Mongo.Aggregate<Mongo.Single<Mongo.CollectionStats>> = .init(
            collection.name,
            stride: nil)
        {
            $0[stage: .collectionStats] = .init
            {
                $0[.storageStats] = [:]
            }

            //  A typical collection stats output document contains a huge amount of
            //  data, most of which is redundant.
            $0[stage: .project] = .init
            {
                for key:Mongo.CollectionStats.Storage.CodingKey
                    in Mongo.CollectionStats.Storage.CodingKey.allCases
                {
                    $0[Mongo.CollectionStats[.storage] /
                        Mongo.CollectionStats.Storage[key]] = true
                }
            }
        }

        return try await self.run(command: command, against: collection.database)
    }
}
