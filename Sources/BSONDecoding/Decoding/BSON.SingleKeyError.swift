import TraceableErrors

extension BSON
{
    @frozen public
    enum SingleKeyError<CodingKey>:Equatable, Error
    {
        case none
        case multiple
    }
}
extension BSON.SingleKeyError:NamedError
{
    /// The name of the error.
    ///
    /// We customize this because otherwise the catcher of this error will mostly likely see
    /// the coding key type name as `CodingKey`, and that wouldn’t be very helpful.
    public
    var name:String
    {
        "DocumentKeyError<\(String.init(reflecting: CodingKey.self))>"
    }
    public
    var message:String
    {
        switch self
        {
        case .none:
            "no keys in single-field document"
        case .multiple:
            "multiple keys in single-field document"
        }
    }
}
