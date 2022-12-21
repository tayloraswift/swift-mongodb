extension Mongo.ReplicaSetConfiguration
{
    @frozen public
    struct ResidentRights:Sendable
    {
        public
        let buildsIndexes:Bool
        public
        let isHidden:Bool
        public
        let votes:Int
        // TODO: model delay

        @inlinable public
        init(buildsIndexes:Bool = true, isHidden:Bool = false, votes:Int)
        {
            self.buildsIndexes = buildsIndexes
            self.isHidden = isHidden
            self.votes = votes
        }
    }
}
