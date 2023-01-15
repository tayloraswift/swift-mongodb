import Durations
import MongoSchema

extension Mongo
{
    public
    struct CursorIterator<Element> where Element:MongoDecodable
    {
        public
        let id:Mongo.CursorIdentifier
        /// The read preference used to obtain the initial cursor. This must be restated
        /// for each subsequent ``GetMore`` command when reading from non-master nodes.
        public
        let preference:Mongo.ReadPreference
        /// The database and collection this cursor iterates over.
        public
        let namespace:Mongo.Namespaced<Mongo.Collection>
        /// The timeout used for ``GetMore`` operations from this batch sequence.
        /// This will be [`nil`]() for non-tailable cursors.
        public
        let timeout:Milliseconds?
        /// The maximum size of each batch retrieved by this batch sequence.
        public
        let stride:Int
        /// The session and connection used to advance the associated cursor.
        /// Cursors can only be iterated over a specific connection to a specific
        /// server.
        public
        let pinned:
        (
            connection:Mongo.Connection,
            session:Mongo.Session
        )
        public
        let pool:Mongo.ConnectionPool

        init(cursor id:Mongo.CursorIdentifier,
            preference:Mongo.ReadPreference,
            namespace:Mongo.Namespaced<Mongo.Collection>,
            timeout:Milliseconds?,
            stride:Int,
            pinned:
            (
                connection:Mongo.Connection,
                session:Mongo.Session
            ),
            pool:Mongo.ConnectionPool)
        {
            self.id = id
            self.preference = preference
            self.namespace = namespace
            self.timeout = timeout
            self.stride = stride
            self.pinned = pinned
            self.pool = pool
        }
    }
}
