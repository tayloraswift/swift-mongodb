extension Mongo
{
    public
    struct ReadPreferenceError:Equatable, Error
    {
        public
        let preference:ReadPreference

        public
        init(preference:ReadPreference)
        {
            self.preference = preference
        }
    }
}
extension Mongo.ReadPreferenceError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        Timed out waiting for a server suitable for read preference \
        '\(self.preference)' to join topology.
        """
    }
}
