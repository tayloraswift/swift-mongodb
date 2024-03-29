import BSONEncoding
import MongoQL

func ExampleProjectionDocuments()
{
    let _:Mongo.ProjectionDocument = .init
    {
        $0["expression"] = .expr
        {
            $0[.abs] = "$field"
        }
        $0["key1"] = 1
        $0["key2"] = .expr
        {
            $0[.literal] = 1
        }
        $0["a"] = .init
        {
            $0[.slice] = 1
        }
        $0["b"] = .init
        {
            $0[.slice] = (1, 1)
        }
        $0["c"] = .init
        {
            $0[.meta] = .indexKey
        }
        $0["d"] = .init
        {
            $0[.first] = .init
            {
                $0[.or]
                {
                    $0 { $0["x"] = 5 }
                    $0 { $0["x"] { $0[.gt] = 5 } }
                }
            }
        }
    }
}
