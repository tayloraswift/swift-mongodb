import BSONEncoding
import MongoQL

func ExampleProjectionDocuments()
{
    let _:Mongo.ProjectionDocument<Mongo.AnyKeyPath> = .init
    {
        $0["expression"] { $0[.abs] = "$field" }
        $0["key1"] = true
        $0["key2"] { $0[.literal] = 1 }
        $0["a"] { $0[.slice] = 1 }
        $0["b"] { $0[.slice] = (1, 1) }
        $0["c"] { $0[.meta] = .indexKey }
        $0["d"]
        {
            $0[.first]
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
