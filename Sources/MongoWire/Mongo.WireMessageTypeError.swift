extension Mongo
{
    @frozen public
    struct WireMessageTypeError:Equatable, Error
    {
        public
        let code:Int32

        @inlinable public
        init(invalid code:Int32)
        {
            self.code = code
        }
    }
}
extension Mongo.WireMessageTypeError:CustomStringConvertible
{
    public
    var description:String
    {
        "invalid or unsupported message operation code (\(self.code))"
    }
}
