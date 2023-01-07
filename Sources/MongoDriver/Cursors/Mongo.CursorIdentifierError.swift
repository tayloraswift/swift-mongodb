extension Mongo
{
    public
    struct CursorIdentifierError:Equatable, Error
    {
        public
        let id:CursorIdentifier

        public
        init(invalid id:CursorIdentifier)
        {
            self.id = id
        }
    }
}
extension Mongo.CursorIdentifierError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid cursor identifier '\(self.id)'"
    }
}
