extension Mongo
{
    public
    struct ServerSelectionError:Equatable, Error
    {
        public
        let selector:ServerSelector

        init(_ selector:ServerSelector)
        {
            self.selector = selector
        }
    }
}
extension Mongo.ServerSelectionError:CustomStringConvertible
{
    public
    var description:String
    {
        "could not connect to any hosts matching selector '\(self.selector)'"
    }
}
