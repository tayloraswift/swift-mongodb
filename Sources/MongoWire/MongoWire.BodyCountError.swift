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
            "reply contained no body document"
        case .multiple:
            "reply contained multiple body documents"
        }
    }
}
