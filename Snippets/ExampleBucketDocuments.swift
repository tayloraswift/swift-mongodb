import BSON
import MongoQL

func ExampleBucketDocuments()
{
    let _:Mongo.BucketDocument = .init
    {
        $0[.groupBy] { $0[.first] = "$field" }
        $0[.default] = 0
        $0[.boundaries] = [0, 1]
    }
    let _:Mongo.BucketDocument = .init
    {
        $0[.groupBy] { $0[.abs] = "$field" }
        $0[.default] = 0
        $0[.boundaries] = .init
        {
            $0[+] = "$field"
            $0(BSON.Key.self)
            {
                $0["x"] = "y"
            }
        }
    }
}
