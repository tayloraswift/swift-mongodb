import BSONEncoding
import MongoQL

func ExamplePredicateDocuments()
{
    let _:Mongo.PredicateDocument = .init
    {
        $0["a"] = 0
        $0["b"]
        {
            $0["key"] = "value"
        }
        $0["c"]
        {
            $0[.gt] = 5
            $0[.mod] = (by: 5, is: 2)
        }
    }
    let _:Mongo.PredicateDocument = .init
    {
        $0[.and]
        {
            $0
            {
                $0["c"]
                {
                    $0[.gt] = 5
                    $0[.mod] = (by: 5, is: 2)
                }
            }
            $0
            {
                $0[.or]
                {
                    $0
                    {
                        $0["key"] = false
                    }
                    $0
                    {
                        $0["key"]
                        {
                            $0[.in] = [1, 2, 3]
                            $0[.type] = .decimal128
                        }
                    }
                }
            }
        }
    }
}
