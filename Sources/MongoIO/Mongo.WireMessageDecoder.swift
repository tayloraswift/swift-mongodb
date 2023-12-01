import BSON
import MongoWire
import NIOCore

extension Mongo
{
    public
    struct WireMessageDecoder
    {
        public
        typealias InboundOut = MongoWire.Message<ByteBufferView>

        private
        var header:MongoWire.Header?

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
        let header:MongoWire.Header
        if let seen:MongoWire.Header = self.header
        {
            header = seen
        }
        else if MongoWire.Header.size <= buffer.readableBytes
        {
            header = try buffer.readWithUnsafeInput
            {
                try $0.parse(as: MongoWire.Header.self)
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
        let message:MongoWire.Message<ByteBufferView> = try buffer.readWithInput
        {
            try $0.parse(as: MongoWire.Message<ByteBufferView>.self, header: header)
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
