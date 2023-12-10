extension Mongo
{
    public
    enum WireBodyCountError:Equatable, Error
    {
        case none
        case multiple
    }
}
extension Mongo.WireBodyCountError:CustomStringConvertible
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
