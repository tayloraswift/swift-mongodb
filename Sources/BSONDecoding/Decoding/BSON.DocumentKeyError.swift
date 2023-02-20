extension BSON
{
    /// A document had an invalid key scheme.
    @frozen public
    enum DocumentKeyError<Key>:Error
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
extension BSON.DocumentKeyError:CustomStringConvertible
{
    public
    var description:String
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
