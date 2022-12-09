extension Mongo
{
    public
    struct Peerlist:Sendable
    {
        /// The current
        /// [primary](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-primary)
        /// member of the replica set.
        public
        let primary:Mongo.Host?

        /// The list of all members of the replica set that are
        /// [arbiters](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-arbiter).
        public
        let arbiters:[Mongo.Host]

        /// The list of all members of the replica set which have a
        /// [priority](https://www.mongodb.com/docs/manual/reference/replica-configuration/#mongodb-rsconf-rsconf.members-n-.priority)
        /// of 0.
        public
        let passives:[Mongo.Host]

        /// The list of all members of the replica set that are neither
        /// [hidden](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-hidden-member),
        /// [passive](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-passive-member),
        /// nor [arbiters](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-arbiter).
        public
        let hosts:[Mongo.Host]

        /// The member of the replica set that returned this response.
        public
        let me:Mongo.Host?

        public
        init(primary:Mongo.Host?,
            arbiters:[Mongo.Host],
            passives:[Mongo.Host],
            hosts:[Mongo.Host],
            me:Mongo.Host?)
        {
            self.primary = primary
            self.arbiters = arbiters
            self.passives = passives
            self.hosts = hosts
            self.me = me
        }
    }
}
extension Mongo.Peerlist
{
    func peers() -> Set<Mongo.Host>
    {
        // primary should already be in `self.hosts`
        var peers:Set<Mongo.Host> = []
            peers.formUnion(self.arbiters)
            peers.formUnion(self.passives)
            peers.formUnion(self.hosts)
        return peers
    }
}
