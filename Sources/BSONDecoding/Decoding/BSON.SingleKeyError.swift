extension BSON
{
    @frozen public
    enum SingleKeyError<CodingKey>:Equatable, Error
    {
        case none
        case multiple
    }
}
extension BSON.SingleKeyError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .none:
            return "no keys in single-field document"
        case .multiple:
            return "multiple keys in single-field document"
        }
    }
}
