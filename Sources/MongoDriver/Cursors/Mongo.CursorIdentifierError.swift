extension Mongo
{
    @frozen public
    struct CursorIdentifierError:Equatable, Error
    {
        public
        let expected:CursorIdentifier
        public
        let invalid:CursorIdentifier

        @inlinable public
        init(expected:CursorIdentifier, invalid:CursorIdentifier)
        {
            self.expected = expected
            self.invalid = invalid
        }
    }
}
extension Mongo.CursorIdentifierError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid cursor identifier '\(self.invalid)', expected '\(self.expected)'"
    }
}
