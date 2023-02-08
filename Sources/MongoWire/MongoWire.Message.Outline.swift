extension MongoWire.Message
{
    @frozen public
    struct Outline:Identifiable
    {
        public
        let id:String
        /// An opaque buffer, which is expected to contain a sequence of
        /// BSON documents, packed without separators. This is a different
        /// format from a BSON tuple-document.
        public
        let slice:Bytes

        @inlinable public
        init(id:String, slice:Bytes)
        {
            self.id = id
            self.slice = slice
        }
    }
}
extension MongoWire.Message.Outline
{
    /// The size of this outline, in bytes, when encoded in a message
    /// with its header.
    @inlinable public
    var size:Int
    {
        5 + self.id.utf8.count + self.slice.count
    }
}
extension MongoWire.Message.Outline:Sendable where Bytes:Sendable
{
}
