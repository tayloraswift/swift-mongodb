import BSONSchema

extension Mongo
{
    @frozen public
    struct CursorHandle:Hashable, RawRepresentable, Sendable
    {
        public
        let rawValue:Int64

        @inlinable public
        init(rawValue:Int64)
        {
            self.rawValue = rawValue
        }
    }
}
extension Mongo.CursorHandle:BSONScheme
{
}
