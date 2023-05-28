import BSONEncoding
import MongoBuiltins
import MongoDSL

func TestExpressions()
{
    let _:BSON.Document = .init
    {
        $0["_"] = [] as [Never]
        $0["_"] = [:]
        $0["_"]
        {
            $0["_"]
            {
                $0["_"] = [:]
            }
        }
    }
    let _:BSON.Document = .init
    {
        $0["foo"] = "$field"
        $0["bar"]
        {
            $0["ccc"] = 56
        }
        $0["qux"]
        {
            $0.append(56)
        }
    }
    let _:MongoExpression = .init
    {
        $0["_"] =  nil as            Never??
        $0["_"] = (nil as Never?) as Never??
        $0["_"] = false
        $0["_"] = true
        $0["_"] = [] as [Never]
        $0["_"] = [:]
        $0["_"] = .init
        {
            $0.append(0)
        }
        $0["_"] = .init
        {
            $0["_"] = 0
        }
        $0["_"] = .init
        {
            $0[.in] = (0, .init
            {
                $0.append(0)
            })
        }
        $0["_"] = .init
        {
            $0[.abs] = .init
            {
                $0[.abs] = "$field"
            }
        }
    }
    let _:MongoExpression = .init
    {
        $0[.abs] = .init
        {
            $0[.abs] = "$field"
        }
    }
    let _:MongoExpression = .init
    {
        $0["_"] = .init
        {
            $0[.abs] = "$field"
        }
        $0["_"] = .init
        {
            $0[.add] = "$a"
        }
        $0["_"] = .init
        {
            $0[.add] = ("$a", "$b")
        }
        $0["_"] = .init
        {
            $0[.add] = ("$a", "$b", "$c")
        }
        $0["_"] = .init
        {
            $0[.add] = ["$a"]
        }
        $0["_"] = .init
        {
            $0[.add] = .init
            {
                $0.append("$a")
            }
        }
        $0["_"] = .init
        {
            $0[.ceil] = "$field"
        }
        $0["_"] = .init
        {
            $0[.divide] = ("$field", by: 2)
        }
        $0["_"] = .init
        {
            $0[.exp] = "$field"
        }
        $0["_"] = .init
        {
            $0[.floor] = "$field"
        }
        $0["_"] = .init
        {
            $0[.ln] = "$field"
        }
        $0["_"] = .init
        {
            $0[.log] = (base: 2, of: "$field")
        }
        $0["_"] = .init
        {
            $0[.log10] = "$field"
        }
        $0["_"] = .init
        {
            $0[.mod] = ("$field", by: 2)
        }
        $0["_"] = .init
        {
            $0[.multiply] = "$a"
        }
        $0["_"] = .init
        {
            $0[.multiply] = ("$a", "$b")
        }
        $0["_"] = .init
        {
            $0[.pow] = (base: 2, to: "$field")
        }
        $0["_"] = .init
        {
            $0[.round] = "$field"
        }
        $0["_"] = .init
        {
            $0[.round] = ("$field", places: 2)
        }
        $0["_"] = .init
        {
            $0[.sqrt] = "$field"
        }
        $0["_"] = .init
        {
            $0[.subtract] = ("$field", minus: 2)
        }
        $0["_"] = .init
        {
            $0[.trunc] = "$field"
        }
        $0["_"] = .init
        {
            $0[.trunc] = ("$field", places: 2)
        }
    }
    let _:MongoExpression = .init
    {
        $0["_"] = .init
        {
            $0[.cmp] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.eq] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.gt] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.gte] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.lt] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.lte] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.ne] = ("$x", 0)
        }
    }
    let _:MongoExpression = .init
    {
        $0["_"] = .init
        {
            $0[.and] = ("$x", true)
        }
        $0["_"] = .init
        {
            $0[.or] = .init
            {
                $0.append
                {
                    $0[.and] = ("$x", .init
                    {
                        $0[.eq] = ("$y", 5)
                    })
                }
            }
        }
        $0["_"] = .init
        {
            $0[.eq] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.gt] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.gte] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.lt] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.lte] = ("$x", 0)
        }
        $0["_"] = .init
        {
            $0[.ne] = ("$x", 0)
        }
    }
    let _:MongoExpression = .init
    {
        $0["_"] = .init
        {
            $0[.element] = (of: "$field", at: 0)
        }
        $0["_"] = .init
        {
            $0[.arrayToObject] = "$field"
        }
        $0["_"] = .init
        {
            $0[.concatArrays] = "$field"
        }
        $0["_"] = .init
        {
            $0[.concatArrays] = ("$field", [] as [Never])
        }
        $0["_"] = .init
        {
            $0[.filter] = .init
            {
                $0[.for] = "x"
                $0[.input] = [0, 1, 2]
                $0[.where] = .init
                {
                    $0[.gt] = ("$$x", 0)
                }
                $0[.limit] = 10
            }
        }
        $0["_"] = .init
        {
            $0[.first] = "$field"
        }
        $0["_"] = .init
        {
            $0[.first] = (5, of: "$field")
        }
        $0["_"] = .init
        {
            $0[.in] = ("$field", in: [4, 5, 6])
        }
        $0["_"] = .init
        {
            $0[.elementIndex] = (in: "$field", of: 5.5, from: 0, to: nil as Never?)
        }
        $0["_"] = .init
        {
            $0[.elementIndex] = (in: "$field", of: 5.5)
        }
        $0["_"] = .init
        {
            $0[.isArray] = "$field"
        }
        $0["_"] = .init
        {
            $0[.last] = "$field"
        }
        $0["_"] = .init
        {
            $0[.last] = (5, of: "$field")
        }
        $0["_"] = .init
        {
            $0[.map] = .init
            {
                $0[.for] = "x"
                $0[.input] = [0, 1, 2]
                $0[.transform] = .init
                {
                    $0[.add] = ("$$x", 1)
                }
            }
        }
        $0["_"] = .init
        {
            $0[.max] = (5, of: "$field")
        }
        $0["_"] = .init
        {
            $0[.min] = (5, of: "$field")
        }
        $0["_"] = .init
        {
            $0[.not] = "$field"
        }
        $0["_"] = .init
        {
            $0[.objectToArray] = "$field"
        }
        $0["_"] = .init
        {
            $0[.range] = (from: "$start", to: "$end", by: 2)
        }
        $0["_"] = .init
        {
            $0[.range] = (from: "$start", to: "$end")
        }
        $0["_"] = .init
        {
            $0[.reduce] = .init
            {
                $0[.input] = [0, 1, 2]
                $0[.initialValue] = 0
                $0[.combine] = .init
                {
                    $0[.add] = ("$$value", "$$this")
                }
            }
        }
        $0["_"] = .init
        {
            $0[.reverseArray] = "$field"
        }
        $0["_"] = .init
        {
            $0[.size] = "$field"
        }
        $0["_"] = .init
        {
            $0[.slice] = ("$field", distance: -5)
        }
        $0["_"] = .init
        {
            $0[.slice] = ("$field", at: -2, distance: 1)
        }
        $0["_"] = .init
        {
            $0[.sortArray] = .init
            {
                $0[.input] = "$field"
                $0[.by] = .init
                {
                    $0["x"] = (+)
                    $0["y"] = (-)
                }
            }
        }
        $0["_"] = .init
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", "$y")
                $0[.defaults] = [0, 0]
            }
        }
        $0["_"] = .init
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", [1, 2])
                $0[.defaults] = [0, 0]
            }
        }
        $0["_"] = .init
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", .init
                {
                    $0.append(1)
                    $0.append(2)
                })
                $0[.defaults] = [0, 0]
            }
        }
    }
}

