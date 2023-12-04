import BSON
import Durations
import MongoABI

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
        /// The lifecycle mode of this cursor. This is
        /// ``case CursorLifecycle.iterable(_:)`` for tailable cursors, and
        /// ``case CursorLifecycle.expires(_:)`` for non-tailable cursors.
        @usableFromInline
        let lifecycle:CursorLifecycle
        /// The operation timeout used for ``KillCursors``, and the default
        /// operation timeout used for ``GetMore`` for tailable cursors without
        /// an explicit timeout set.
        @usableFromInline
        let timeout:Milliseconds
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

        init(cursor id:CursorIdentifier,
            preference:ReadPreference,
            namespace:Namespaced<Mongo.Collection>,
            lifecycle:CursorLifecycle,
            timeout:Milliseconds,
            stride:Int,
            pinned:
            (
                connection:Connection,
                session:Session
            ))
        {
            self.id = id
            self.preference = preference
            self.namespace = namespace
            self.lifecycle = lifecycle
            self.timeout = timeout
            self.stride = stride
            self.pinned = pinned
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
            .now.advanced(by: .milliseconds(timeout ?? self.timeout))

        case .expires(let deadline):
            deadline
        }
    }
}
extension Mongo.CursorIterator
{
    /// Runs a ``GetMore`` command from this cursor. This operation will set a
    /// deadline for itself depending on the cursor’s ``lifecycle`` mode.
    ///
    /// -   If the cursor is **tailable** with a user-specified timeout
    ///     (``case CursorLifecycle.iterable(_:)``), the deadline will be the
    ///     current time, advanced by that timeout.
    ///
    /// -   If the cursor is **tailable** with no user-specified timeout
    ///     (``case CursorLifecycle.iterable(_:)``), the deadline will be the
    ///     current time, advanced by the default operation timeout.
    ///
    /// -   If the cursor is **non-tailable** (``case CursorLifecycle.expires(_:)``),
    ///     the deadline will be the same as the deadline that was set for the
    ///     command that obtained the cursor.
    ///
    /// If this method throws an error, attempting to call it again is not
    /// recommended, and the cursor should be discarded.
    @inlinable public
    func get<Element>(more _:Element.Type) async throws -> Mongo.Cursor<Element>.Batch
        where Element:BSONDecodable
    {
        try await self.pinned.session.run(
            command: Mongo.GetMore<Element>.init(cursor: self.id,
                collection: self.namespace.collection,
                timeout: self.lifecycle.timeout,
                count: self.stride),
            against: self.namespace.database,
            over: self.pinned.connection,
            on: self.preference,
            by: self.deadline())
    }
    /// Runs a ``KillCursors`` command for this cursor. This operation sets its
    /// own deadline using the default operation timeout for this cursor, regardless
    /// of when the cursor was obtained or last iterated.
    @usableFromInline
    func kill() async throws -> Mongo.KillCursorsResponse
    {
        try await self.pinned.session.run(
            command: Mongo.KillCursors.init(self.namespace.collection, cursors: [self.id]),
            against: self.namespace.database,
            over: self.pinned.connection,
            on: self.preference,
            //  ``KillCursors`` always refreshes the timeout
            by: .now.advanced(by: .milliseconds(self.timeout)))
    }
}
