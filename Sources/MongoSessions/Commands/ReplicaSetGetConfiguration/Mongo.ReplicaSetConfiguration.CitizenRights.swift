extension Mongo.ReplicaSetConfiguration
{
    @frozen public
    struct CitizenRights:Sendable
    {
        public
        let priority:Double
        public
        let votes:Int

        @inlinable public
        init()
        {
            self.priority = 1
            self.votes = 1
        }

        @inlinable public
        init?(priority:Double, votes:Int)
        {
            if  priority > 0,
                votes > 0
            {   
                self.priority = priority
                self.votes = votes
            }
            else
            {
                return nil
            }
        }
    }
}
