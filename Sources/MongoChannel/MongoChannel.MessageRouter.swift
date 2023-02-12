import BSONEncoding
import MongoWire
import NIOCore

extension MongoChannel
{
    public final
    class MessageRouter
    {
        private
        var request:MongoWire.MessageIdentifier
        private
        var state:State

        public
        init()
        {
            // MongoDB uses 0 as the ‘nil’ id.
            self.request = .none
            self.state = .awaiting(nil)
        }

        deinit
        {
            if case .awaiting(_?) = self.state
            {
                fatalError("unreachable (deinitialized channel handler while a continuation is still awaiting")
            }
        }
    }
}
extension MongoChannel.MessageRouter
{
    func perish(throwing error:any Error)
    {
        switch self.state
        {
        case .awaiting(let continuation):
            continuation?.resume(throwing: error)
            self.state = .perished
        
        case .perished:
            break
        }
    }
}
extension MongoChannel.MessageRouter:ChannelInboundHandler
{
    public
    typealias InboundIn = MongoWire.Message<ByteBufferView>
    public
    typealias InboundOut = Never

    public
    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        let message:MongoWire.Message<ByteBufferView> = self.unwrapInboundIn(data)

        switch self.state
        {
        case .awaiting(let continuation?):
            guard self.request == message.header.request
            else
            {
                fallthrough
            }

            continuation.resume(returning: message)
            self.state = .awaiting(nil)
        
        case .awaiting(nil):
            self.state = .perished
            context.fireErrorCaught(MongoChannel.MessageRoutingError.init(
                unknown: message.header.request))
        
        case .perished:
            break
        }
    }
    public
    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.perish(throwing: error)
        
        context.fireErrorCaught(error)
    }
    public
    func channelInactive(context:ChannelHandlerContext)
    {
        self.perish(throwing: MongoChannel.DisconnectionError.init())

        context.fireChannelInactive()
    }
}
extension MongoChannel.MessageRouter:ChannelOutboundHandler
{
    public
    typealias OutboundIn = MongoChannel.Action
    public
    typealias OutboundOut = ByteBuffer

    public
    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        switch self.unwrapOutboundIn(data)
        {
        case .interrupt:
            self.perish(throwing: MongoChannel.InterruptError.init())

            context.channel.close(mode: .all, promise: nil)
        
        case .timeout:
            self.perish(throwing: MongoChannel.TimeoutError.init(sent: true))

            context.channel.close(mode: .all, promise: nil)
        
        case .request(let command, let continuation):
            let request:MongoWire.MessageIdentifier = self.request.next()
            let message:MongoWire.Message<[UInt8]> = .init(
                sections: command,
                checksum: false,
                id: request)
            
            switch self.state
            {
            case .perished:
                continuation.resume(throwing: MongoChannel.DisconnectionError.init())
                return
            
            case .awaiting(_?):
                fatalError("submitted a command to a channel that is already running a command")
            
            case .awaiting(nil):
                self.state = .awaiting(continuation)
            }

            var output:BSON.Output<ByteBufferView> = .init(
                preallocated: .init(context.channel.allocator.buffer(
                    capacity: .init(message.header.size))))
            
            output.serialize(message: message)
            context.writeAndFlush(self.wrapOutboundOut(ByteBuffer.init(output.destination)),
                promise: promise)
        }
    }
}
