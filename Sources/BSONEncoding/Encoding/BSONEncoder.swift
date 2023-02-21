import BSON

public
protocol BSONEncoder
{
    init(output:BSON.Output<[UInt8]>)
    var output:BSON.Output<[UInt8]> { get }

    static
    var type:BSON { get }
}
