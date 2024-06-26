import BSONEncoding
import MongoQL

func ExampleAccumulators()
{
    let _:Mongo.Accumulator = .init
    {
        $0[.top] = .init
        {
            $0[.output] = "$field"
            $0[.by, using: Mongo.AnyKeyPath.self]
            {
                $0["x"] = (+)
                $0["y"] = (-)
            }
        }
    }
    let _:Mongo.Accumulator = .init
    {
        $0[.top] = .init
        {
            $0[.output] = "$field"
            $0[.n] = 5
            $0[.by, using: Mongo.AnyKeyPath.self]
            {
                $0["x"] = (+)
                $0["y"] = (-)
            }
        }
    }
    let _:Mongo.Accumulator = .init
    {
        $0[.first] = .init
        {
            $0[.input] = "$field"
            $0[.n] = 5
        }
    }
    let _:Mongo.Accumulator = .init
    {
        $0[.first] = "$field"
    }
}
