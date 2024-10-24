import MongoDB
import Testing

@Suite
struct ChangeStreams:Mongo.TestBattery
{
    let collection:Mongo.Collection = "Subscriptions"
    let database:Mongo.Database = "ChangeStreams"

    //  Change streams only work with replica sets.
    @Test(arguments: [.replicated] as [any Mongo.TestConfiguration])
    func changeStreams(_ configuration:any Mongo.TestConfiguration) async throws
    {
        try await self.run(under: configuration)
    }

    func run(with pool:Mongo.SessionPool) async throws
    {
        let session:Mongo.Session = try await .init(from: pool)

        let state:(Plan, Plan, Plan) =
        (
            .init(id: 1, owner: "a", level: "x"),
            .init(id: 1, owner: "a", level: "y"),
            .init(id: 1, owner: "b", level: "y")
        )

        var changes:[Mongo.Change<PlanDelta>] = [
            .insert(state.0),
            .update(.init(updatedFields: .init(owner: nil, level: "y"),
                    id: state.0.id),
                before: nil,
                after: nil),
            .replace(.init(updatedFields: nil,
                    id: state.0.id),
                before: nil,
                after: state.2),
            .delete(.init(id: state.0.id))
        ]

        changes.reverse()

        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<
                Mongo.ChangeEvent<PlanDelta>>>.init(self.collection,
                writeConcern: .majority,
                readConcern: .majority,
                //  This is always needed, otherwise the cursor will die after a fixed
                //  amount of time.
                tailing: .init(timeout: .milliseconds(4_000), awaits: true),
                stride: 10)
            {
                $0[stage: .changeStream] { _ in }
            },
            against: self.database,
            //  We set this to an artificially low value to check that the cursor tailing
            //  is working properly.
            by: .now.advanced(by: .seconds(2)))
        {
            var poll:Int = 0
            for try await batch:[Mongo.ChangeEvent<PlanDelta>] in $0
            {
                defer
                {
                    poll += 1
                }
                if  poll == 0
                {
                    #expect(batch.count == 0)

                    let _:Task<Void, any Error> = .init
                    {
                        let session:Mongo.Session = try await .init(from: pool)


                        let _:Mongo.InsertResponse = try await session.run(
                            command: Mongo.Insert.init(self.collection, encoding: [state.0]),
                            against: self.database)

                        let _:Mongo.UpdateResponse = try await session.run(
                            command: Mongo.Update<Mongo.One, Int>.init(self.collection)
                            {
                                $0[.ordered] = true
                            }
                                updates:
                            {
                                $0
                                {
                                    $0[.q] { $0[Plan[.id]] = state.0.id }
                                    $0[.u]
                                    {
                                        $0[.set] { $0[Plan[.level]] = state.1.level }
                                    }
                                }

                                $0
                                {
                                    $0[.q] { $0[Plan[.id]] = state.0.id }
                                    $0[.u] = state.2
                                }
                            },
                            against: self.database)

                        let _:Mongo.DeleteResponse = try await session.run(
                            command: Mongo.Delete<Mongo.One>.init(self.collection)
                            {
                                $0
                                {
                                    $0[.q] { $0[Plan[.id]] = state.0.id }
                                    $0[.limit] = .one
                                }
                            },
                            against: self.database)
                    }
                }
                else if poll > 5
                {
                    //  If more than 5 polling intervals have passed and we still haven't
                    //  received the expected changes, then the test has failed.
                    #expect(changes == [])
                    return
                }

                //  It is rare, but MongoDB does occasionally coalesce multiple changes into
                //  one cursor batch.
                for event:Mongo.ChangeEvent<PlanDelta> in batch
                {
                    guard
                    let expected:Mongo.Change<PlanDelta> = changes.popLast()
                    else
                    {
                        #expect(event == nil)
                        return
                    }

                    #expect(event.change == expected)

                    if  changes.isEmpty
                    {
                        return
                    }
                }
            }
        }
    }
}
