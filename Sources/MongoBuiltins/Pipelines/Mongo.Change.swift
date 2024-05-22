import MongoABI

extension Mongo
{
    @frozen public
    enum Change<Delta> where Delta:MasterCodingDelta, Delta.Model:Identifiable
    {
        /// Replacement is similar to a normal ``update(_:before:after:)``, but the
        /// `DocumentUpdate` instance will only include the
        /// ``ChangeUpdateRepresentation/DocumentKey`` of the replaced document, and
        /// additionally, it
        /// [always includes](https://github.com/mongodb/specifications/blob/master/source/change-streams/change-streams.rst#server-specification)
        /// the post-image document.
        ///
        /// The case layout wraps the entire `DocumentUpdate` and not just its `_id` field, for
        /// future compatibility with sharded collections.
        case replace(Update, before:Delta.Model?, after:Delta.Model)
        /// A document update that was not a full replacement. This type of event includes
        /// information about the changed fields.
        ///
        /// The event might include pre- and post-images, if the collection was configured for
        /// that. The document images might include unrelated changes, as they respect
        /// majority read concern.
        case update(Update, before:Delta.Model?, after:Delta.Model?)
        /// Deletion is similar to an ``update(_:before:after:)``, but the `DocumentUpdate`
        /// instance will only include the ``ChangeUpdateRepresentation/DocumentKey`` of the
        /// deleted document.
        ///
        /// The case layout wraps the entire `DocumentUpdate` and not just its `_id` field, for
        /// future compatibility with sharded collections.
        case delete(Update)
        /// A document insertion. The payload is the inserted document.
        case insert(Delta.Model)

        case _unimplemented
    }
}
extension Mongo.Change:Equatable where Update:Equatable, Delta.Model:Equatable
{
}
extension Mongo.Change:Sendable where Update:Sendable, Delta.Model:Sendable
{
}
