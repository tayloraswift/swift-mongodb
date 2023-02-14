import BSONEncoding
import MongoBuiltins

func TestProjectionDocuments()
{
    let _:Mongo.ProjectionDocument = .init
    {
        $0["expression"] = .init
        {
            $0[.abs] = "$field"
        }
        $0["key1"] = 1
        $0["key2"] = .init
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
                $0[.or] = 
                [
                    .init
                    {
                        $0["x"] = 5
                    },
                    .init
                    {
                        $0["x"] = .init
                        {
                            $0[.gt] = 5
                        }
                    },
                ]
            }
        }
    }
}
