import BSON

extension Mongo
{
    @frozen public
    struct WireHeader:Identifiable, Sendable
    {
        /// The number of bytes in the message body, *not* including the header.
        public
        let count:Int
        /// The identifier for this message.
        public
        let id:WireMessageIdentifier
        /// The request this message is a response to.
        public
        let request:WireMessageIdentifier
        /// The type of this message.
        public
        let type:WireMessageType

        @inlinable public
        init(count:Int, id:WireMessageIdentifier,
            request:WireMessageIdentifier = .none,
            type:WireMessageType = .message)
        {
            self.count = count
            self.id = id
            self.request = request
            self.type = type
        }
    }
}
extension Mongo.WireHeader
{
    /// The size, 16 bytes, of a MongoDB message header.
    public static
    let size:Int = 16

    @inlinable public
    var size:Int32
    {
        .init(Self.size + self.count)
    }

    @inlinable public
    init(size:Int32, id:Int32, request:Int32, type:Int32) throws
    {
        guard let type:Mongo.WireMessageType = .init(rawValue: type)
        else
        {
            throw Mongo.WireMessageTypeError.init(invalid: type)
        }
        self.init(count: Int.init(size) - Self.size, id: .init(id), request: .init(request),
            type: type)
    }
}


extension Mongo.WireHeader:CustomStringConvertible
{
    public
    var description:String
    {
        """
        {
            size: \(self.size)
            message id: \(self.id.value)
            response to: \(self.request.value)
            type: \(self.type)
        }
        """
    }
}
