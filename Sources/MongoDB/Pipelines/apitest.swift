import BSONEncoding

func _test()
{
    let _:BSON.Fields = .init
    {
        $0["foo"] = "$field"
        $0["bar"] = .init
        {
            $0["ccc"] = 56
        }
        $0[pushing: "baz"] = .init
        {
            $0[.abs] = 56
        }
        $0["qux"] = .init
        {
            $0.append(56)
        }
    }
    let _:MongoExpression = .init
    {
        $0[.abs] = .init
        {
            $0[.abs] = "$field"
        }
    }
    let _:Mongo.PredicateDocument = .init
    {
        $0["a"] = 0
        // $0["b"] = .init
        // {
        //     $0["key"] = "value"
        // }
        // $0["c"] = .init
        // {
        //     $0[.gt] = 5
        //     $0[.mod] = (by: 5, is: 2)
        // }
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
    let _:Mongo.BucketDocument = .init
    {
        $0[.by] = .init
        {
            $0[.abs] = "$field"
        }
        $0[.default] = .init
        {
            $0[.abs] = "$field"
        }
        $0[.by] = .init
        {
            $0[.first] = "$field"
        }
        $0[.boundaries] = [0, 1]
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
