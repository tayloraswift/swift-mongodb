extension BSON
{
    /// A type that can be (efficiently) decoded from a BSON variant value
    /// backed by a preferred type of storage particular to the decoded type.
    ///
    /// This protocol is parallel and unrelated to ``BSONDecodable`` to
    /// emphasize the performance characteristics of types that conform to
    /// this protocol and not ``BSONDecodable``.
    public
    typealias FrameView = _BSONFrameView
}

/// The name of this protocol is ``BSON.FrameView``.
public
protocol _BSONFrameView<Bytes>:BSON.FrameTraversable, Equatable
{
    /// Attempts to cast a BSON variant backed by ``Bytes`` to an instance
    /// of this view type without copying the contents of the backing storage.
    init(_:BSON.AnyValue<Bytes>) throws
}
