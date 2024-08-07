import MongoDriver
import Testing_

func TestReadPreference(_ tests:TestGroup, members:Mongo.Seedlist,
    bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "read-preferences"
    else
    {
        return
    }

    await tests.do
    {
        try await bootstrap.withSessionPool
        {
            let session:Mongo.Session = try await .init(from: $0)
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
                    .primaryPreferred(tagSets: [["name": "A", "priority": "high"]])
                ),
                //  We should be able to select the primary even if
                //  none of the tags match.
                (
                    "primary-preferred-no-matches",
                    .primaryPreferred(tagSets: [["name": "Z"]])
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
                    .nearest(tagSets: [])
                ),
                //  A tag set list with a single, empty tag set should
                //  behave the same as no tag set list.
                (
                    "nearest-empty-tag-set",
                    .nearest(tagSets: [[:]])
                ),
                //  A tag set list with many empty tag sets should
                //  behave the same as no tag set list.
                (
                    "nearest-empty-tag-sets",
                    .nearest(tagSets: [[:], [:]])
                ),
                //  We should be able to select a replica by specifying
                //  all of its tags.
                (
                    "nearest-tagged",
                    .nearest(tagSets: [["name": "A", "priority": "high"]])
                ),
                //  We should be able to select a replica by specifying
                //  some of its tags.
                (
                    "nearest-tagged-name-A",
                    .nearest(tagSets: [["name": "A"]])
                ),
                //  Moreover, all non-hidden replicas should qualify for
                //  nearest read preference.
                (
                    "nearest-tagged-name-B",
                    .nearest(tagSets: [["name": "B"]])
                ),
                (
                    "nearest-tagged-name-C",
                    .nearest(tagSets: [["name": "C"]])
                ),
                //  A secondary should qualify for nearest read preference.
                (
                    "nearest-tagged-priority-zero",
                    .nearest(tagSets: [["priority": "zero"]])
                ),
                //  If we use a maximum staleness of zero, we should still be
                //  able to select the primary. (Because the primary has
                //  zero staleness by definition.)
                (
                    "nearest-staleness-zero",
                    .nearest(maxStaleness: .zero)
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
                    .primaryPreferred(tagSets: [["name": "Z"]])
                ),
                //  A secondary should qualify for secondary-preferred
                //  read preference.
                (
                    "secondary-preferred-priority-zero",
                    .secondaryPreferred(tagSets: [["priority": "zero"]])
                ),
                //  We should be able to select a member by tag sets
                //  as long as one set matches.
                (
                    "secondary-preferred-multiple-tag-sets",
                    .secondaryPreferred(tagSets: [["name": "Z"], ["priority": "zero"]])
                ),
                //  It follows that we should be able to select a member
                //  by tag sets as long as one set is empty.
                (
                    "secondary-preferred-multiple-tag-sets",
                    .secondaryPreferred(tagSets: [["name": "Z"], [:]])
                ),
                //  We should be able to select any secondary with
                //  secondary read preference.
                (
                    "secondary",
                    .secondary
                ),
            ]
            {
                await (tests / name)?.do
                {
                    try await session.run(
                        command: Mongo.RefreshSessions.init(session.id),
                        against: .admin,
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
                    .nearest(tagSets: [["name": "Z"]])
                ),
                //  We should not be able to select a member if any of
                //  the tag set patterns do not match, even if some of
                //  them do match.
                (
                    "nearest-partial-match",
                    .nearest(tagSets: [["name": "A", "priority": "bananas"]])
                ),
            ]
            {
                await (tests / name)?.do(
                    catching: Mongo.DeploymentStateError<Mongo.ReadPreferenceError>.init(
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
            if  let tests:TestGroup = tests / "secondary-staleness-zero"
            {
                await tests.do(
                    catching: Mongo.DeploymentStateError<Mongo.ReadPreferenceError>.self)
                {
                    try await session.refresh(on: .secondary(maxStaleness: .zero))
                }
            }
        }
    }
}
