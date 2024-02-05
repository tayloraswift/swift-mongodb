import BSON
import CRC

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
extension Mongo.WireHeader
{
    @inlinable public static
    func parse(from input:inout BSON.Input) throws -> Self
    {
        // total size, including this
        let size:Int32 = try input.parse(as: Int32.self)
        let id:Int32 = try input.parse(as: Int32.self)
        let request:Int32 = try input.parse(as: Int32.self)
        let type:Int32 = try input.parse(as: Int32.self)
        return try .init(size: size, id: id, request: request, type: type)
    }

    @inlinable public
    func parse(from input:inout BSON.Input) throws -> Mongo.WireMessage
    {
        let flags:Mongo.WireFlags = try .init(validating: try input.parse(as: UInt32.self))

        let sections:Mongo.WireMessage.Sections = try .parse(from: &input)

        let checksum:CRC32? = flags.contains(.checksumPresent)
            ? .init(checksum: try input.parse(as: UInt32.self))
            : nil

        return .init(header: self, flags: flags, sections: sections, checksum: checksum)
    }
}
extension Mongo.WireHeader
{
    @inlinable internal static
    func += (output:inout some BSON.OutputStream, self:Self)
    {
        // the `as` coercions are here to prevent us from accidentally
        // changing the types of the various integers, which ``serialize(integer:)``
        // depends on.
        output.serialize(integer: self.size as Int32)
        output.serialize(integer: self.id.value as Int32)
        output.serialize(integer: self.request.value as Int32)
        output.serialize(integer: self.type.rawValue as Int32)
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
