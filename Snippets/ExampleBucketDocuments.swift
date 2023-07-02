import BSONEncoding
import MongoBuiltins

func ExampleBucketDocuments()
{
    let _:Mongo.BucketDocument = .init
    {
        $0[.by] = .expr
        {
            $0[.first] = "$field"
        }
        $0[.default] = .expr
        {
            $0[.abs] = "$field"
        }
        $0[.boundaries] = [0, 1]
    }
    let _:Mongo.BucketDocument = .init
    {
        $0[.by] = .expr
        {
            $0[.abs] = "$field"
        }
        $0[.default] = .expr
        {
            $0[.abs] = "$field"
        }
        $0[.boundaries] = .init
        {
            $0.append("$field")
            $0.append
            {
                $0["x"] = "y"
            }
        }
    }
}
