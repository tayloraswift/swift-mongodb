extension Mongo.WireMessage
{
    @frozen public
    struct Outline:Identifiable, Sendable
    {
        public
        let id:String
        /// An opaque buffer, which is expected to contain a sequence of
        /// BSON documents, packed without separators. This is a different
        /// format from a BSON tuple-document.
        public
        let slice:ArraySlice<UInt8>

        @inlinable public
        init(id:String, slice:ArraySlice<UInt8>)
        {
            self.id = id
            self.slice = slice
        }
    }
}
extension Mongo.WireMessage.Outline
{
    /// The size of this outline, in bytes, when encoded in a message
    /// with its header.
    @inlinable public
    var size:Int
    {
        5 + self.id.utf8.count + self.slice.count
    }
}
