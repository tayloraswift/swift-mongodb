import BSON
import BSONStream
import MongoWire
import NIOCore

extension MongoIO
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
extension MongoIO.MessageRouter
{
    func perish(throwing error:MongoIO.ExecutionError)
    {
        switch self.state
        {
        case .awaiting(let continuation):
            continuation?.resume(returning: .failure(error))
            self.state = .perished
        
        case .perished:
            break
        }
    }
}
extension MongoIO.MessageRouter:ChannelInboundHandler
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

            continuation.resume(returning: .success(message))
            self.state = .awaiting(nil)
        
        case .awaiting(nil):
            self.state = .perished
            context.fireErrorCaught(MongoIO.MessageRoutingError.init(
                unknown: message.header.request))
        
        case .perished:
            break
        }
    }
    public
    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.perish(throwing: .network(error: .other(error)))
        
        context.fireErrorCaught(error)
    }
    public
    func channelInactive(context:ChannelHandlerContext)
    {
        self.perish(throwing: .network(error: .disconnected))

        context.fireChannelInactive()
    }
}
extension MongoIO.MessageRouter:ChannelOutboundHandler
{
    public
    typealias OutboundIn = MongoIO.Action
    public
    typealias OutboundOut = ByteBuffer

    public
    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        switch self.unwrapOutboundIn(data)
        {
        case .interrupt:
            self.perish(throwing: .network(error: .interrupted))

            context.channel.close(mode: .all, promise: nil)
        
        case .timeout:
            self.perish(throwing: .timeout)

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
                continuation.resume(returning: .failure(.network(error: .disconnected)))
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
