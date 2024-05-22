import BSON
import MongoWire
import NIOCore

extension Mongo
{
    public final
    class WireMessageRouter
    {
        private
        var request:Mongo.WireMessageIdentifier
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
            if  case .awaiting(_?) = self.state
            {
                fatalError("""
                    unreachable (deinitialized channel handler while a continuation is still \
                    awaiting)
                    """)
            }
        }
    }
}
extension Mongo.WireMessageRouter
{
    func perish(throwing error:any Error)
    {
        switch self.state
        {
        case .awaiting(let caller?):
            caller.fail(error)
            self.state = .perished(nil)

        case .awaiting(nil):
            self.state = .perished(error)

        case .perished:
            break
        }
    }
}
extension Mongo.WireMessageRouter:ChannelInboundHandler
{
    public
    typealias InboundIn = Mongo.WireMessage
    public
    typealias InboundOut = Never

    public
    func channelRead(context:ChannelHandlerContext, data:NIOAny)
    {
        let message:Mongo.WireMessage = self.unwrapInboundIn(data)

        switch self.state
        {
        case .awaiting(let caller?):
            guard self.request == message.header.request
            else
            {
                fallthrough
            }

            caller.succeed(message)
            self.state = .awaiting(nil)

        case .awaiting(nil):
            self.state = .perished(nil)
            context.fireErrorCaught(Mongo.WireMessageRoutingError.init(
                unknown: message.header.request))

        case .perished:
            break
        }
    }
    public
    func channelInactive(context:ChannelHandlerContext)
    {
        self.perish(throwing: Mongo.NetworkError.init(
            underlying: Mongo.WireProtocolError.interrupted))

        context.fireChannelInactive()
    }
    public
    func errorCaught(context:ChannelHandlerContext, error:any Error)
    {
        self.perish(throwing: Mongo.NetworkError.init(underlying: error))

        context.fireErrorCaught(error)
    }
}
extension Mongo.WireMessageRouter:ChannelOutboundHandler
{
    public
    typealias OutboundIn = Mongo.WireAction
    public
    typealias OutboundOut = ByteBuffer

    public
    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        switch self.unwrapOutboundIn(data)
        {
        case .cancel(let error):
            self.perish(throwing: error)

            context.channel.close(mode: .all, promise: nil)

        case .request(let command, let caller):
            let request:Mongo.WireMessageIdentifier = self.request.next()
            let message:Mongo.WireMessage = .init(
                sections: command,
                checksum: false,
                id: request)

            switch self.state
            {
            case .perished:
                caller.fail(Mongo.NetworkError.init(
                    underlying: Mongo.WireProtocolError.interruptedAlready))
                return

            case .awaiting(_?):
                fatalError("submitted a command to a channel that is already running a command")

            case .awaiting(nil):
                self.state = .awaiting(caller)
            }

            var output:Mongo.WireMessageEncoder = .init(
                buffer: context.channel.allocator.buffer(capacity: .init(message.header.size)))

            output += message

            context.writeAndFlush(self.wrapOutboundOut(output.buffer),
                promise: promise)
        }
    }
}
