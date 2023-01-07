import Atomics
import BSONEncoding
import MongoWire
import NIOCore

extension MongoChannel
{
    public final
    class MessageRouter
    {
        private
        let counter:UnsafeAtomic<Int32>
        private
        let timeout:Duration
        private
        var requests:
        [
            MongoWire.MessageIdentifier:
                CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>
        ]

        public
        init(timeout:Duration)
        {
            // MongoDB uses 0 as the ‘nil’ id.
            self.counter = .create(1)
            self.timeout = timeout
            self.requests = [:]
        }

        deinit
        {
            self.counter.destroy()
            for (id, continuation):
            (
                MongoWire.MessageIdentifier,
                CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>
            )   in self.requests
            {
                continuation.resume(throwing: TimeoutError.init(awaiting: id))
            }
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
        let request:MongoWire.MessageIdentifier = message.header.request
        if  let continuation:CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error> = 
                self.requests.removeValue(forKey: request)
        {
            continuation.resume(returning: message)
        }
        else
        {
            context.fireErrorCaught(MongoChannel.MessageRoutingError.init(unknown: request))
            return
        }
    }
}
extension MongoChannel.MessageRouter:ChannelOutboundHandler
{
    public
    typealias OutboundIn =
    (
        BSON.Fields,
        CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error>
    )
    public
    typealias OutboundOut = ByteBuffer

    public
    func write(context:ChannelHandlerContext, data:NIOAny, promise:EventLoopPromise<Void>?)
    {
        let (command, continuation):OutboundIn = self.unwrapOutboundIn(data)
        
        let id:MongoWire.MessageIdentifier = .init(self.counter.loadThenWrappingIncrement(
            ordering: .relaxed))
        let message:MongoWire.Message<[UInt8]> = .init(sections: .init(body: .init(command)),
            checksum: false,
            id: id)
        
        guard case nil = self.requests.updateValue(continuation, forKey: id)
        else
        {
            fatalError("unreachable: atomic counter is broken!")
        }

        var output:BSON.Output<ByteBufferView> = .init(
            preallocated: .init(context.channel.allocator.buffer(
                capacity: .init(message.header.size))))
        
        output.serialize(message: message)
        context.writeAndFlush(self.wrapOutboundOut(ByteBuffer.init(output.destination)),
            promise: promise)
        
        Task.init
        {
            [weak self, id, timeout] in

            try? await Task.sleep(for: timeout)
            if  let self:MongoChannel.MessageRouter,
                let continuation:CheckedContinuation<MongoWire.Message<ByteBufferView>, any Error> = 
                    self.requests.removeValue(forKey: id)
            {
                continuation.resume(throwing: MongoChannel.TimeoutError.init(awaiting: id,
                    for: timeout))
            }
        }
    }
}
