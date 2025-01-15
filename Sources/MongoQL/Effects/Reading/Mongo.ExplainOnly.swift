import BSON
import BSONReflection

extension Mongo
{
    @frozen public
    enum ExplainOnly
    {
    }
}
extension Mongo.ExplainOnly:Mongo.ReadEffect
{
    public
    typealias Tailing = Never
    public
    typealias Stride = Never
    public
    typealias Batch = String
    public
    typealias BatchElement = Never

    public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key>) -> String
    {
        var output:String = ""
        let indent:BSON.Indent = "    " + 1
        for (key, value):(BSON.Key, BSON.AnyValue) in reply.indexedFields.sorted(
            by: { $0.key < $1.key })
        {
            switch key
            {
            case "ok", "operationTime", "$clusterTime":
                continue

            case let key:
                indent.print(key: key, value: value, to: &output)
            }
        }

        return "{\(output)\n}"
    }
}
