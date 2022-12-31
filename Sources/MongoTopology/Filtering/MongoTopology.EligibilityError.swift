extension MongoTopology
{
    public
    struct EligibilityError:Equatable, Error
    {
        public
        let unsuitable:[Rejection<Unsuitable>]

        public
        init(unsuitable:[Rejection<Unsuitable>] = [])
        {
            self.unsuitable = unsuitable
        }
    }
}
