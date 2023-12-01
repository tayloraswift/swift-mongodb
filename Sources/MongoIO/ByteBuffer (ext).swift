import BSON
import NIOCore

extension ByteBuffer
{
    mutating
    func readWithInput<T>(
        parser parse:(inout BSON.Input<ByteBufferView>) throws -> T) rethrows -> T
    {
        var input:BSON.Input<ByteBufferView> = .init(self.readableBytesView)
        let parsed:T = try parse(&input)
        self.moveReaderIndex(forwardBy: input.source.distance(from: input.source.startIndex,
            to: input.index))
        return parsed
    }
    mutating
    func readWithUnsafeInput<T>(
        parser parse:(inout BSON.Input<UnsafeRawBufferPointer>) throws -> T) rethrows -> T
    {
        try self.readWithUnsafeReadableBytes
        {
            (buffer:UnsafeRawBufferPointer) throws -> (Int, T) in

            var input:BSON.Input<UnsafeRawBufferPointer> = .init(buffer)
            let parsed:T = try parse(&input)
            let advanced:Int = input.source.distance(from: input.source.startIndex,
                to: input.index)
            return (advanced, parsed)
        }
    }
}
