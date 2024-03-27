import BSON
import MongoDB
import MongoTesting

struct ChangeStreams<Configuration>:MongoTestBattery where Configuration:MongoTestConfiguration
{
    static
    func run(tests:TestGroup, pool:Mongo.SessionPool, database:Mongo.Database) async throws
    {
        let collection:Mongo.Collection = "subscriptions"

        await tests.do
        {
            typealias ChangeEvent = Mongo.ChangeEvent<Plan, Mongo.ChangeUpdate<PlanDelta, Int>>
            typealias Change = Mongo.ChangeOperation<Plan, Mongo.ChangeUpdate<PlanDelta, Int>>

            let session:Mongo.Session = try await .init(from: pool)

            let state:(Plan, Plan, Plan) =
            (
                .init(id: 1, owner: "a", level: "x"),
                .init(id: 1, owner: "a", level: "y"),
                .init(id: 1, owner: "b", level: "y")
            )
            var changes:[Change] = [
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
                command: Mongo.Aggregate<Mongo.Cursor<ChangeEvent>>.init(collection,
                    writeConcern: .majority,
                    readConcern: .majority,
                    //  This is always needed, otherwise the cursor will die after a fixed
                    //  amount of time.
                    tailing: .init(timeout: 4_000, awaits: true),
                    stride: 10)
                {
                    $0[stage: .changeStream] { _ in }
                },
                against: database,
                //  We set this to an artificially low value to check that the cursor tailing
                //  is working properly.
                by: .now.advanced(by: .seconds(2)))
            {
                var poll:Int = 0
                for try await batch:[ChangeEvent] in $0
                {
                    defer
                    {
                        poll += 1
                    }
                    if  poll == 0
                    {
                        tests.expect(batch.count ==? 0)

                        let _:Task<Void, any Error> = .init
                        {
                            let session:Mongo.Session = try await .init(from: pool)


                            let _:Mongo.InsertResponse = try await session.run(
                                command: Mongo.Insert.init(collection, encoding: [state.0]),
                                against: database)

                            let _:Mongo.UpdateResponse = try await session.run(
                                command: Mongo.Update<Mongo.One, Int>.init(collection)
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
                                against: database)

                            let _:Mongo.DeleteResponse = try await session.run(
                                command: Mongo.Delete<Mongo.One>.init(collection)
                                {
                                    $0
                                    {
                                        $0[.q] { $0[Plan[.id]] = state.0.id }
                                        $0[.limit] = .one
                                    }
                                },
                                against: database)
                        }
                    }
                    else if
                        let document:ChangeEvent = batch.first
                    {
                        guard
                        let expected:Change = changes.popLast()
                        else
                        {
                            tests.expect(nil: document)
                            return
                        }

                        tests.expect(document.operation ==? expected)

                        if  changes.isEmpty
                        {
                            return
                        }
                    }
                    else if poll > 5
                    {
                        //  If more than 5 polling intervals have passed and we still haven't
                        //  received the expected changes, then the test has failed.
                        tests.expect(changes ..? [])
                        return
                    }
                }
            }
        }
    }
}
