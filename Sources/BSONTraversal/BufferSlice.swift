#if swift(>=9999)

@_moveOnly
@frozen public
struct BufferSlice
{
    @usableFromInline internal
    let storage:Unmanaged<AnyObject>
    public
    let bytes:UnsafeRawBufferPointer

    @inlinable public
    init(retaining storage:Unmanaged<AnyObject>, bytes:UnsafeRawBufferPointer)
    {
        self.storage = storage.retain()
        self.bytes = bytes
    }

    @inlinable
    deinit
    {
        self.storage.release()
    }
}
extension BufferSlice
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.bytes.elementsEqual(rhs.bytes)
    }
}
extension BufferSlice
{
    @inlinable public
    init(_ other:__shared Self)
    {
        self.init(retaining: other.storage, bytes: other.bytes)
    }
}
extension BufferSlice
{
    @inlinable public __consuming
    func slice(_ range:some RangeExpression<Int>) -> Self
    {
        .init(retaining: self.storage, bytes: .init(rebasing: self.bytes[range]))
    }
}

#endif
