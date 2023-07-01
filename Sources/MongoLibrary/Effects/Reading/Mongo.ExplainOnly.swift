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
    typealias CommandResponse = Void
    public
    typealias Element = Never
    public
    typealias Tailing = Never
    public
    typealias Stride = Void

    public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>)
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

        print("{\(output)\n}")
    }
}
