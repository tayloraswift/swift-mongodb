public
protocol CollectionViewBSON<Bytes>:Equatable
{
    /// The backing storage used by this type. It is recommended that 
    /// implementations satisfy this with generics.
    associatedtype Bytes:RandomAccessCollection<UInt8>

    init(_:AnyBSON<Bytes>) throws
}
