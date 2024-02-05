import BSON
import NIOCore

extension Mongo
{
    struct WireMessageEncoder
    {
        var buffer:ByteBuffer

        init(buffer:ByteBuffer)
        {
            self.buffer = buffer
        }
    }
}
extension Mongo.WireMessageEncoder:BSON.OutputStream
{
    mutating
    func append(_ byte:UInt8)
    {
        self.buffer.writeInteger(byte)
    }
    mutating
    func append(_ bytes:some Sequence<UInt8>)
    {
        self.buffer.writeBytes(bytes)
    }
}
