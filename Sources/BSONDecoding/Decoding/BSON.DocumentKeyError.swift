import TraceableErrors

extension BSON
{
    /// A document had an invalid key scheme.
    @frozen public
    enum DocumentKeyError<Key>:Error where Key:Sendable
    {
        /// A document contained more than one field with the same key.
        case duplicate(Key)
        /// A document did not contain a field with the expected key.
        case undefined(Key)
    }
}
extension BSON.DocumentKeyError:Equatable where Key:Equatable
{
}
extension BSON.DocumentKeyError:NamedError
{
    /// The name of the error.
    ///
    /// We customize this because otherwise the catcher of this error will mostly likely see
    /// the coding key type name as `CodingKey`, and that wouldn’t be very helpful.
    public
    var name:String
    {
        "DocumentKeyError<\(String.init(reflecting: Key.self))>"
    }
    public
    var message:String
    {
        switch self
        {
        case .duplicate(let key):
            return "duplicate key '\(key)'"
        case .undefined(let key):
            return "undefined key '\(key)'"
        }
    }
}
