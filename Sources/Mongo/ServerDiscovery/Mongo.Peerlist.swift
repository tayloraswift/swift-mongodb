extension Mongo
{
    public
    struct Peerlist:Sendable
    {
        /// The name of the relevant replica set.
        /// This is called `setName` in the server reply.
        public
        let set:String

        /// The current
        /// [primary](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-primary)
        /// member of the relevant replica set.
        public
        let primary:Host?

        /// The list of all members of the relevant replica set that are
        /// [arbiters](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-arbiter).
        public
        let arbiters:[Host]

        /// The list of all members of the relevant replica set which have a
        /// [priority](https://www.mongodb.com/docs/manual/reference/replica-configuration/#mongodb-rsconf-rsconf.members-n-.priority)
        /// of 0.
        public
        let passives:[Host]

        /// The list of all members of the relevant replica set that are neither
        /// [hidden](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-hidden-member),
        /// [passive](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-passive-member),
        /// nor [arbiters](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-arbiter).
        public
        let hosts:[Host]

        /// The member of the relevant replica set that returned this response.
        public
        let me:Host?

        public
        init(set:String,
            primary:Host?,
            arbiters:[Host],
            passives:[Host],
            hosts:[Host],
            me:Host?)
        {
            self.set = set
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
        for host:Mongo.Host in [self.arbiters, self.passives, self.hosts].joined()
        {
            peers.insert(host)
        }
        return peers
    }
    func peers(besides existing:Dictionary<Mongo.Host, some Any>.Keys) -> Set<Mongo.Host>
    {
        var inserted:Set<Mongo.Host> = []
        for host:Mongo.Host in [self.arbiters, self.passives, self.hosts].joined()
            where !existing.contains(host)
        {
            inserted.insert(host)
        }
        return inserted
    }
}
