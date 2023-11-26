import BSONTypes

public
protocol BSONEncoder
{
    init(_:consuming BSON.Output<[UInt8]>)

    consuming
    func move() -> BSON.Output<[UInt8]>

    static
    var type:BSON { get }
}
