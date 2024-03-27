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

            let session:Mongo.Session = try await .init(from: pool)

            let state:(Plan, PlanDelta) =
            (
                .init(id: 1, owner: "a", level: "x"),
                .init(owner: nil, level: "y")
            )
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
                var insertSeen:Bool = false
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
                                    $0
                                    {
                                        $0[.q] { $0[Plan[.id]] = 1 }
                                        $0[.u]
                                        {
                                            $0[.set] { $0[Plan[.level]] = state.1.level }
                                        }
                                    }
                                },
                                against: database)
                        }
                    }
                    else if insertSeen,
                        let document:ChangeEvent = batch.first
                    {
                        guard
                        case .update(let update, before: _, after: _) = document.operation
                        else
                        {
                            tests.expect(value: nil as Mongo.ChangeUpdate<PlanDelta, Int>?)
                            return
                        }

                        tests.expect(update.id ==? state.0.id)
                        tests.expect(update.updatedFields ==? state.1)
                        tests.expect(update.removedFields ==? [])
                        tests.expect(update.truncatedArrays ==? [])
                        return
                    }
                    else if
                        let event:ChangeEvent = batch.first
                    {
                        guard
                        case .insert(let document) = event.operation
                        else
                        {
                            tests.expect(value: nil as Plan?)
                            return
                        }

                        tests.expect(document ==? state.0)
                        insertSeen = true
                    }
                    else if poll > 5
                    {
                        //  If more than 5 polling intervals have passed and we still haven't
                        //  received any documents, then the test has failed.
                        tests.expect(true: false)
                    }
                }
            }
        }
    }
}
