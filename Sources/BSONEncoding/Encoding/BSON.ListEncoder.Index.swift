extension BSON.ListEncoder
{
    /// A syntactical abstraction used to express the “end index” of a list. This type has no
    /// inhabitants.
    @frozen public
    enum Index {}
}
extension BSON.ListEncoder.Index
{
    /// A syntactical symbol used to express the “end index” of an list.
    @inlinable public
    static prefix func + (_:Self) {}
}
