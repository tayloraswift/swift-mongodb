extension BSON
{
    public
    protocol Encoder<Frame>
    {
        associatedtype Frame:BufferFrame

        static
        var frame:Frame { get }

        init(_:consuming Output)

        consuming
        func move() -> Output
    }
}
