extension BSON
{
    public
    typealias Encoder = _BSONEncoder
}

/// The name of this protocol is ``BSON.Encoder``.
public
protocol _BSONEncoder
{
    init(_:consuming BSON.Output<[UInt8]>)

    consuming
    func move() -> BSON.Output<[UInt8]>

    static
    var type:BSON.AnyType { get }
}
