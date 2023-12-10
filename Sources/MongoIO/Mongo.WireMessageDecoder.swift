import BSON
import MongoWire
import NIOCore

extension Mongo
{
    public
    struct WireMessageDecoder
    {
        public
        typealias InboundOut = Mongo.WireMessage<ByteBufferView>

        private
        var header:Mongo.WireHeader?

        public
        init()
        {
            self.header = nil
        }
    }
}
extension Mongo.WireMessageDecoder:ByteToMessageDecoder
{
    public mutating
    func decode(context:ChannelHandlerContext,
        buffer:inout ByteBuffer) throws -> DecodingState
    {
        let header:Mongo.WireHeader
        if let seen:Mongo.WireHeader = self.header
        {
            header = seen
        }
        else if Mongo.WireHeader.size <= buffer.readableBytes
        {
            header = try buffer.readWithUnsafeInput
            {
                try $0.parse(as: Mongo.WireHeader.self)
            }
        }
        else
        {
            return .needMoreData
        }

        guard header.count <= buffer.readableBytes
        else
        {
            self.header = header
            return .needMoreData
        }

        self.header = nil
        let message:Mongo.WireMessage<ByteBufferView> = try buffer.readWithInput
        {
            try $0.parse(as: Mongo.WireMessage<ByteBufferView>.self, header: header)
        }
        context.fireChannelRead(self.wrapInboundOut(message))
        return .continue
    }

    public mutating
    func decodeLast(context:ChannelHandlerContext,
        buffer:inout ByteBuffer,
        seenEOF _:Bool) throws -> DecodingState
    {
        try self.decode(context: context, buffer: &buffer)
    }
}
