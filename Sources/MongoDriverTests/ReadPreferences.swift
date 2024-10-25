import MongoConfiguration
import MongoDriver
import NIOPosix
import Testing

@Suite struct ReadPreferences
{
    @Test
    static func readPreferences() async throws
    {
        let members:Mongo.Seedlist = .replicated
        let bootstrap:Mongo.DriverBootstrap = mongodb / members /?
        {
            $0.connectionTimeout = .milliseconds(250)
            $0.executors = .shared(MultiThreadedEventLoopGroup.singleton)
        }

        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
            for preference:Mongo.ReadPreference in [
                .primary,
                .primaryPreferred,
                //  We should be able to select the primary regardless
                //  of tag sets.
                .primaryPreferred(tagSets: [["name": "A", "priority": "high"]]),
                //  We should be able to select the primary even if
                //  none of the tags match.
                .primaryPreferred(tagSets: [["name": "Z"]]),
                //  We should be able to select any replica with nearest
                //  read preference.
                .nearest,
                //  An empty tag set list should behave the same as no
                //  tag set list.
                .nearest(tagSets: []),
                //  A tag set list with a single, empty tag set should
                //  behave the same as no tag set list.
                .nearest(tagSets: [[:]]),
                //  A tag set list with many empty tag sets should
                //  behave the same as no tag set list.
                .nearest(tagSets: [[:], [:]]),
                //  We should be able to select a replica by specifying
                //  all of its tags.
                .nearest(tagSets: [["name": "A", "priority": "high"]]),
                //  We should be able to select a replica by specifying
                //  some of its tags.
                .nearest(tagSets: [["name": "A"]]),
                //  Moreover, all non-hidden replicas should qualify for
                //  nearest read preference.
                .nearest(tagSets: [["name": "B"]]),
                .nearest(tagSets: [["name": "C"]]),
                //  A secondary should qualify for nearest read preference.
                .nearest(tagSets: [["priority": "zero"]]),
                //  If we use a maximum staleness of zero, we should still be
                //  able to select the primary. (Because the primary has
                //  zero staleness by definition.)
                .nearest(maxStaleness: .zero),
                //  We should be able to select any replica with
                //  secondary-preferred read preference.
                .secondaryPreferred,
                //  We should be able to select the primary even if
                //  none of the tags match.
                .primaryPreferred(tagSets: [["name": "Z"]]),
                //  A secondary should qualify for secondary-preferred
                //  read preference.
                .secondaryPreferred(tagSets: [["priority": "zero"]]),
                //  We should be able to select a member by tag sets
                //  as long as one set matches.
                .secondaryPreferred(tagSets: [["name": "Z"], ["priority": "zero"]]),
                //  It follows that we should be able to select a member
                //  by tag sets as long as one set is empty.
                .secondaryPreferred(tagSets: [["name": "Z"], [:]]),
                //  We should be able to select any secondary with
                //  secondary read preference.
                .secondary,
            ]
            {
                try await session.run(
                    command: Mongo.RefreshSessions.init(session.id),
                    against: .admin,
                    on: preference)
            }

            for preference:Mongo.ReadPreference in [
                //  We should not be able to select the primary with
                //  nearest read preference if none of the tags match.
                //  (Because eligibility applies to the primary.)
                .nearest(tagSets: [["name": "Z"]]),
                //  We should not be able to select a member if any of
                //  the tag set patterns do not match, even if some of
                //  them do match.
                .nearest(tagSets: [["name": "A", "priority": "bananas"]]),
            ]
            {
                await #expect(
                    throws: Mongo.DeploymentStateError<Mongo.ReadPreferenceError>.init(
                        diagnostics: .init(
                            undesirable:
                            [
                                members[5]: .arbiter,
                            ],
                            unsuitable:
                            [
                                members[0]: .tags(["name": "A", "priority": "high"]),
                                members[1]: .tags(["name": "B", "priority": "low"]),
                                members[2]: .tags(["name": "C", "priority": "zero"]),
                                members[3]: .tags(["name": "D", "priority": "zero"]),
                                members[6]: .tags(["name": "E", "priority": "zero"]),
                            ]),
                        failure: .init(preference: preference)))
                {
                    try await session.refresh(on: preference)
                }
            }
            // We should never be able to select a secondary with zero staleness.
            await #expect(throws: Mongo.DeploymentStateError<Mongo.ReadPreferenceError>.self)
            {
                try await session.refresh(on: .secondary(maxStaleness: .zero))
            }
        }
    }
}
