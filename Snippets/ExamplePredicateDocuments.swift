import BSONEncoding
import MongoQL

func ExamplePredicateDocuments()
{
    let _:Mongo.PredicateDocument = .init
    {
        $0["a"] = 0
        $0["b"] = .init
        {
            $0["key"] = "value"
        }
        $0["c"] = .init
        {
            $0[.gt] = 5
            $0[.mod] = (by: 5, is: 2)
        }
    }
    let _:Mongo.PredicateDocument = .init
    {
        $0[.and] = .init
        {
            $0.append
            {
                $0["c"] = .init
                {
                    $0[.gt] = 5
                    $0[.mod] = (by: 5, is: 2)
                }
            }
            $0.append
            {
                $0[.or] =
                [
                    .init
                    {
                        $0["key"] = false
                    },
                    .init
                    {
                        $0["key"] = .init
                        {
                            $0[.in] = [1, 2, 3]
                            $0[.type] = .decimal128
                        }
                    },
                ]
            }
        }
    }
}
