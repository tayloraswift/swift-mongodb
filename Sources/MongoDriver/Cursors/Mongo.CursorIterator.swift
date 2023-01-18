import Durations
import MongoSchema

extension Mongo
{
    /// A cursor iterable is an immutable (but non-``Sendable``) structure
    /// containing all of the information needed to ``get(more:)`` data from
    /// a server.
    public
    struct CursorIterator
    {
        public
        let id:CursorIdentifier
        /// The read preference used to obtain the initial cursor. This must be restated
        /// for each subsequent ``GetMore`` command when reading from non-master nodes.
        public
        let preference:ReadPreference
        /// The database and collection this cursor iterates over.
        public
        let namespace:Namespaced<Collection>
        @usableFromInline
        let lifecycle:CursorLifecycle
        /// The operation timeout used for ``KillCursors``, and the default
        /// operation timeout used for ``GetMore`` for tailable cursors without
        /// an explicit timeout set.
        @usableFromInline
        let timeout:Mongo.OperationTimeout
        /// The maximum size of each batch retrieved by this batch sequence.
        public
        let stride:Int
        /// The session and connection used to advance the associated cursor.
        /// Cursors can only be iterated over a specific connection to a specific
        /// server.
        @usableFromInline
        let pinned:
        (
            connection:Connection,
            session:Session
        )
        @usableFromInline
        let pool:ConnectionPool

        init(cursor id:CursorIdentifier,
            preference:ReadPreference,
            namespace:Namespaced<Mongo.Collection>,
            lifecycle:CursorLifecycle,
            timeout:Mongo.OperationTimeout,
            stride:Int,
            pinned:
            (
                connection:Connection,
                session:Session
            ),
            pool:ConnectionPool)
        {
            self.id = id
            self.preference = preference
            self.namespace = namespace
            self.lifecycle = lifecycle
            self.timeout = timeout
            self.stride = stride
            self.pinned = pinned
            self.pool = pool
        }
    }
}
extension Mongo.CursorIterator
{
    @usableFromInline
    func deadline() -> ContinuousClock.Instant
    {
        switch self.lifecycle
        {
        case .iterable(let timeout):
            return (timeout ?? self.timeout).deadline()
        case .expires(let deadline):
            return deadline
        }
    }
}
extension Mongo.CursorIterator
{
    @inlinable public
    func get<Element>(more _:Element.Type) async throws -> Mongo.Cursor<Element>
        where Element:MongoDecodable
    {
        try await self.pinned.session.run(
            command: Mongo.GetMore<Element>.init(cursor: self.id,
                collection: self.namespace.collection,
                timeout: self.lifecycle._timeout,
                count: self.stride),
            against: self.namespace.database,
            over: self.pinned.connection,
            on: self.preference,
            by: self.deadline())
    }
    /// Runs ``KillCursors`` for this cursor, without destroying its pinned connection.
    func kill() async throws -> Mongo.KillCursorsResponse
    {
        try await self.pinned.session.run(command: Mongo.KillCursors.init([self.id],
                collection: self.namespace.collection),
            against: self.namespace.database,
            over: self.pinned.connection,
            on: self.preference,
            //  ``KillCursors`` always refreshes the timeout
            by: self.timeout.deadline())
    }
}
