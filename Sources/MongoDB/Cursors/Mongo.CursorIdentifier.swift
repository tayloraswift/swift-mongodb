import BSONSchema

extension Mongo
{
    /// A cursor handle that is guaranteed to be non-null.
    @frozen public
    struct CursorIdentifier:Hashable, Sendable
    {
        public
        let handle:CursorHandle

        @inlinable public
        init?(_ handle:CursorHandle)
        {
            if  handle.rawValue != 0
            {
                self.handle = handle
            }
            else
            {
                return nil
            }
        }
    }
}
extension Mongo.CursorIdentifier:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        self.handle.rawValue
    }
    @inlinable public
    init?(rawValue:Int64)
    {
        self.init(.init(rawValue: rawValue))
    }
}
extension Mongo.CursorIdentifier:BSONScheme
{
}
