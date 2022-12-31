extension MongoTopology
{
    public
    struct SelectionError:Error
    {
        public
        var unreachable:[Rejection<Unreachable>]
        public
        var undesirable:[Rejection<Undesirable>]
        public
        var unsuitable:[Rejection<Unsuitable>]

        public
        init(unreachable:[Rejection<Unreachable>] = [],
            undesirable:[Rejection<Undesirable>] = [],
            unsuitable:[Rejection<Unsuitable>] = [])
        {
            self.unreachable = unreachable
            self.undesirable = undesirable
            self.unsuitable = unsuitable
        }
    }
}
