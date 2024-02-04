extension BSON
{
    public
    typealias Encoder = _BSONEncoder
}

/// The name of this protocol is ``BSON.Encoder``.
public
protocol _BSONEncoder
{
    init(_:consuming BSON.Output)

    consuming
    func move() -> BSON.Output

    static
    var type:BSON.AnyType { get }
}
