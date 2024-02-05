import BSON
import MongoWire
import NIOCore

extension Mongo
{
    public final
    class WireMessageParser
    {
        private
        var header:Mongo.WireHeader?
        private
        var buffer:[UInt8]

        public
        init()
        {
            self.header = nil
            self.buffer = []
            self.buffer.reserveCapacity(Mongo.WireHeader.size)
        }
    }
}
extension Mongo.WireMessageParser
{
    private
    func read(until count:Int, from buffer:inout ByteBuffer) -> Bool
    {
        let length:Int = count - self.buffer.count
        if  buffer.readableBytes < length
        {
            buffer.withUnsafeReadableBytes { self.buffer += $0 }
            buffer.moveReaderIndex(forwardBy: buffer.readableBytes)
            return false
        }
        else
        {
            buffer.withUnsafeReadableBytes { self.buffer += $0.prefix(length) }
            buffer.moveReaderIndex(forwardBy: length)
            return true
        }
    }
}
extension Mongo.WireMessageParser:ChannelInboundHandler
{
    public
    typealias InboundIn = ByteBuffer
    public
    typealias InboundOut = Mongo.WireMessage

    public
    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        do
        {
            var incoming:ByteBuffer = self.unwrapInboundIn(data)
            while 0 < incoming.readableBytes
            {
                switch self.header
                {
                case nil:
                    guard self.read(until: Mongo.WireHeader.size, from: &incoming)
                    else
                    {
                        return
                    }

                    var input:BSON.Input = .init(self.buffer[...])
                    let header:Mongo.WireHeader = try .parse(from: &input)

                    self.buffer = []
                    self.buffer.reserveCapacity(header.count)
                    self.header = header

                case let header?:
                    guard self.read(until: header.count, from: &incoming)
                    else
                    {
                        return
                    }

                    var input:BSON.Input = .init(self.buffer[...])
                    let message:Mongo.WireMessage = try header.parse(from: &input)

                    context.fireChannelRead(self.wrapInboundOut(message))

                    //  We have transferred ownership of the buffer away from this handler,
                    //  so we will need to allocate a new one anyway.
                    self.buffer = []
                    self.buffer.reserveCapacity(Mongo.WireHeader.size)
                    self.header = nil
                }
            }
        }
        catch
        {
            context.fireErrorCaught(error)
        }
    }
    public
    func channelInactive(context:ChannelHandlerContext)
    {
        context.fireChannelInactive()
    }
}
