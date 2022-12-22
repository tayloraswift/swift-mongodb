extension MongoWire
{
    public
    enum BodyCountError:Equatable, Error
    {
        case none
        case multiple
    }
}
extension MongoWire.BodyCountError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .none:
            return "reply contained no body document"
        case .multiple:
            return "reply contained multiple body documents"
        }
    }
}
