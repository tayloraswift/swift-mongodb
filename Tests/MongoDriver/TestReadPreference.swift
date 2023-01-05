import MongoDriver
import MongoTopology
import Testing

func TestReadPreference(_ tests:inout Tests,
    bootstrap:Mongo.DriverBootstrap,
    members:[MongoTopology.Host]) async
{
    await tests.test(name: "read-preferences")
    {
        (tests:inout Tests) in

        try await bootstrap.withSessionPool(seedlist: .init(members))
        {
            try await $0.withSession(connectionTimeout: .milliseconds(250))
            {
                (session:Mongo.Session) in

                for (name, preference):(String, Mongo.ReadPreference) in
                [
                    (
                        "primary",
                        .primary
                    ),
                    (
                        "primary-preferred",
                        .primaryPreferred
                    ),
                    //  We should be able to select the primary regardless
                    //  of tag sets.
                    (
                        "primary-preferred-tagged",
                        .primaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["name": "A", "priority": "high"]]))
                    ),
                    //  We should be able to select the primary even if
                    //  none of the tags match.
                    (
                        "primary-preferred-no-matches",
                        .primaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["name": "Z"]]))
                    ),
                    //  We should be able to select any replica with nearest
                    //  read preference.
                    (
                        "nearest",
                        .nearest
                    ),
                    //  An empty tag set list should behave the same as no
                    //  tag set list.
                    (
                        "nearest-empty-tag-set-list",
                        .nearest(.init(maxStaleness: nil, tagSets: []))
                    ),
                    //  A tag set list with a single, empty tag set should
                    //  behave the same as no tag set list.
                    (
                        "nearest-empty-tag-set",
                        .nearest(.init(maxStaleness: nil, tagSets: [[:]]))
                    ),
                    //  A tag set list with many empty tag sets should
                    //  behave the same as no tag set list.
                    (
                        "nearest-empty-tag-sets",
                        .nearest(.init(maxStaleness: nil, tagSets: [[:], [:]]))
                    ),
                    //  We should be able to select a replica by specifying
                    //  all of its tags.
                    (
                        "nearest-tagged",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "A", "priority": "high"]]))
                    ),
                    //  We should be able to select a replica by specifying
                    //  some of its tags.
                    (
                        "nearest-tagged-name-A",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "A"]]))
                    ),
                    //  Moreover, all non-hidden replicas should qualify for
                    //  nearest read preference.
                    (
                        "nearest-tagged-name-B",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "B"]]))
                    ),
                    (
                        "nearest-tagged-name-C",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "C"]]))
                    ),
                    //  A secondary should qualify for nearest read preference.
                    (
                        "nearest-tagged-priority-zero",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["priority": "zero"]]))
                    ),
                    //  If we use a maximum staleness of zero, we should still be
                    //  able to select the primary. (Because the primary has
                    //  zero staleness by definition.)
                    (
                        "nearest-staleness-zero",
                        .nearest(.init(maxStaleness: 0, tagSets: nil))
                    ),
                    //  We should be able to select any replica with
                    //  secondary-preferred read preference.
                    (
                        "secondary-preferred",
                        .secondaryPreferred
                    ),
                    //  We should be able to select the primary even if
                    //  none of the tags match.
                    (
                        "secondary-preferred-no-matches",
                        .primaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["name": "Z"]]))
                    ),
                    //  A secondary should qualify for secondary-preferred
                    //  read preference.
                    (
                        "secondary-preferred-priority-zero",
                        .secondaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["priority": "zero"]]))
                    ),
                    //  We should be able to select a member by tag sets
                    //  as long as one set matches.
                    (
                        "secondary-preferred-multiple-tag-sets",
                        .secondaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["name": "Z"], ["priority": "zero"]]))
                    ),
                    //  It follows that we should be able to select a member
                    //  by tag sets as long as one set is empty.
                    (
                        "secondary-preferred-multiple-tag-sets",
                        .secondaryPreferred(.init(maxStaleness: nil,
                            tagSets: [["name": "Z"], [:]]))
                    ),
                    //  We should be able to select any secondary with
                    //  secondary read preference.
                    (
                        "secondary",
                        .secondary
                    ),
                ]
                {
                    await tests.test(name: name)
                    {
                        _ in try await session.run(
                            command: Mongo.RefreshSessions.init(session.id),
                            on: preference)
                    }
                }

                for (name, preference):(String, Mongo.ReadPreference) in
                [
                    //  We should not be able to select the primary with
                    //  nearest read preference if none of the tags match.
                    //  (Because eligibility applies to the primary.)
                    (
                        "nearest-no-matches",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "Z"]]))
                    ),
                    //  We should not be able to select a member if any of
                    //  the tag set patterns do not match, even if some of
                    //  them do match.
                    (
                        "nearest-partial-match",
                        .nearest(.init(maxStaleness: nil,
                            tagSets: [["name": "A", "priority": "bananas"]]))
                    ),
                ]
                {
                    await tests.test(name: name,
                        expecting: Mongo.ClusterError<Mongo.ReadPreferenceError>.init(
                            diagnostics: .init(
                                undesirable:
                                [
                                    members[4]: .arbiter,
                                ],
                                unsuitable:
                                [
                                    members[0]: .tags(["name": "A", "priority": "high"]),
                                    members[1]: .tags(["name": "B", "priority": "low"]),
                                    members[2]: .tags(["name": "C", "priority": "zero"]),
                                ]),
                            failure: .init(preference: preference)))
                    {
                        _ in try await session.run(
                            command: Mongo.RefreshSessions.init(session.id),
                            on: preference)
                    }
                }
            }
        }
    }
}
