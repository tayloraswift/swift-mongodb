extension BSON
{
    @frozen public
    struct HeaderError<Frame>:Equatable, Error where Frame:BufferFrame
    {
        public
        let length:Int

        @inlinable public
        init(length:Int)
        {
            self.length = length
        }
    }
}
extension BSON.HeaderError:CustomStringConvertible
{
    public
    var description:String
    {
        """
        length declared in header (\(self.length)) is less than \
        the minimum for '\(Frame.self)' (\(Frame.suffix - Frame.skipped) bytes)
        """
    }
}
