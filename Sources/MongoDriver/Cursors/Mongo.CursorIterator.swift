import Durations
import MongoSchema

extension Mongo
{
    public
    struct CursorIterator<Element> where Element:MongoDecodable
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
        public
        let lifespan:CursorLifespan
        /// The maximum size of each batch retrieved by this batch sequence.
        public
        let stride:Int
        /// The session and connection used to advance the associated cursor.
        /// Cursors can only be iterated over a specific connection to a specific
        /// server.
        public
        let pinned:
        (
            connection:Connection,
            session:Session
        )
        public
        let pool:ConnectionPool

        init(cursor id:CursorIdentifier,
            preference:ReadPreference,
            namespace:Namespaced<Mongo.Collection>,
            lifespan:CursorLifespan,
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
            self.lifespan = lifespan
            self.stride = stride
            self.pinned = pinned
            self.pool = pool
        }
    }
}
