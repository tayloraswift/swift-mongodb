import BSONDecoding
import BSONReflection
import NIOCore

extension Mongo
{
    @frozen public
    enum ExplainOnly
    {
    }
}
extension Mongo.ExplainOnly:MongoReadEffect
{
    public
    typealias Tailing = Never
    /// This is ``Void`` and not `Never?` because we reserve `Never?` for read effects
    /// that return a single batch of results.
    public
    typealias Stride = Void
    public
    typealias Batch = String
    public
    typealias BatchElement = Never

    public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) -> String
    {
        var output:String = ""
        let indent:BSON.Indent = "    " + 1
        for field:BSON.ExplicitField<BSON.Key, ByteBufferView> in
            reply.sorted(by: { $0.key < $1.key })
        {
            switch field.key
            {
            case "ok", "operationTime", "$clusterTime":
                continue

            case let key:
                indent.print(key: key, value: field.value, to: &output)
            }
        }

        return "{\(output)\n}"
    }
}
