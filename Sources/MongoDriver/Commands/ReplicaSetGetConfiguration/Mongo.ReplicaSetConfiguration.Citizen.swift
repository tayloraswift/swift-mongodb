extension Mongo.ReplicaSetConfiguration
{
    /// A configuration for a citizen member. Citizens always cast at least
    /// one vote for primary, and can themselves become primary, based on their
    /// priority.
    @frozen public
    struct Citizen:Equatable, Sendable
    {
        public
        let priority:Double

        /// Configures a citizen with a priority of [`1.0`]().
        @inlinable public
        init()
        {
            self.priority = 1.0
        }
        
        @inlinable public
        init?(priority:Double)
        {
            if  priority > 0
            {   
                self.priority = priority
            }
            else
            {
                return nil
            }
        }
    }
}
