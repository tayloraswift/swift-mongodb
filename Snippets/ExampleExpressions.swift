import BSON
import MongoQL

func ExampleExpressions()
{
    enum Alphabet:String
    {
        case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
    }

    let _:BSON.Document = .init(Alphabet.self)
    {
        $0[.a] = [] as [Never]
        $0[.b] = [:] as Mongo.EmptyDocument
        $0[.c](Alphabet.self)
        {
            $0[.a](BSON.Key.self)
            {
                $0["_"] = [:] as Mongo.EmptyDocument
            }
        }
    }
    let _:BSON.Document = .init(BSON.Key.self)
    {
        $0["foo"] = "$field"
        $0["bar"](BSON.Key.self)
        {
            $0["ccc"] = 56
        }
        $0["qux"](Int.self)
        {
            $0[+] = 56
        }
    }
    let _:BSON.Document = .init(Alphabet.self)
    {
        $0[.a] =  nil as            Never??
        $0[.b] = (nil as Never?) as Never??
        $0[.c] = false
        $0[.d] = true
        $0[.e] = [] as [Never]
        $0[.f] = [:] as Mongo.EmptyDocument
        $0[.g](Int.self)
        {
            $0[+] = 0
        }
        $0[.h](BSON.Key.self)
        {
            $0["_"] = 0
        }
    }

    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a]
        {
            $0[.in] = (0, .init
            {
                $0[+] = 0
            })
        }
        $0[.b]
        {
            $0[.abs]
            {
                $0[.abs] = "$field"
            }
        }
    }
    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a] { $0[.abs] = "$field" }
        $0[.b] { $0[.add] = "$a" }
        $0[.c] { $0[.add] = ("$a", "$b") }
        $0[.d] { $0[.add] = ("$a", "$b", "$c") }
        $0[.e] { $0[.add] = ["$a"] }
        $0[.f] { $0[.add] { $0[+] = "$a" } }
        $0[.g] { $0[.ceil] = "$field" }
        $0[.h] { $0[.divide] = ("$field", by: 2) }
        $0[.i] { $0[.exp] = "$field" }
        $0[.j] { $0[.floor] = "$field" }
        $0[.k] { $0[.ln] = "$field" }
        $0[.l] { $0[.log] = (base: 2, of: "$field") }
        $0[.m] { $0[.log10] = "$field" }
        $0[.n] { $0[.mod] = ("$field", by: 2) }
        $0[.o] { $0[.multiply] = "$a" }
        $0[.p] { $0[.multiply] = ("$a", "$b") }
        $0[.q] { $0[.pow] = (base: 2, to: "$field") }
        $0[.r] { $0[.round] = "$field" }
        $0[.s] { $0[.round] = ("$field", places: 2) }
        $0[.t] { $0[.sqrt] = "$field" }
        $0[.u] { $0[.subtract] = ("$field", minus: 2) }
        $0[.v] { $0[.trunc] = "$field" }
        $0[.w] { $0[.trunc] = ("$field", places: 2) }
    }

    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a] { $0[.cmp] = ("$x", 0) }
        $0[.b] { $0[.eq] = ("$x", 0) }
        $0[.c] { $0[.gt] = ("$x", 0) }
        $0[.d] { $0[.gte] = ("$x", 0) }
        $0[.e] { $0[.lt] = ("$x", 0) }
        $0[.f] { $0[.lte] = ("$x", 0) }
        $0[.g] { $0[.ne] = ("$x", 0) }
    }

    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a]  { $0[.and] = ("$x", true) }
        $0[.b]
        {
            $0[.or]
            {
                $0
                {
                    $0[.and] = ("$x", .expr { $0[.eq] = ("$y", 5) })
                }
            }
        }
        $0[.c] { $0[.eq] = ("$x", 0) }
        $0[.d] { $0[.gte] = ("$x", 0) }
        $0[.e] { $0[.lt] = ("$x", 0) }
        $0[.f] { $0[.lte] = ("$x", 0) }
        $0[.g] { $0[.ne] = ("$x", 0) }
    }

    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a] { $0[.element] = (of: "$field", at: 0) }
        $0[.b] { $0[.arrayToObject] = "$field" }
        $0[.c] { $0[.concatArrays] = "$field" }
        $0[.d] { $0[.concatArrays] = ("$field", [] as [Never]) }
        $0[.e]
        {
            $0[.filter] = .let("x")
            {
                $0[.input] = [0, 1, 2]
                $0[.cond] = .expr { $0[.gt] = ("$$x", 0) }
                $0[.limit] = 10
            }
        }
        $0[.f] { $0[.first] = "$field" }
        $0[.g] { $0[.first] = (5, of: "$field") }
        $0[.h] { $0[.in] = ("$field", in: [4, 5, 6]) }
        $0[.i] { $0[.elementIndex] = (in: "$field", of: 5.5, from: 0, to: nil as Never?) }
        $0[.j] { $0[.elementIndex] = (in: "$field", of: 5.5) }
        $0[.k] { $0[.isArray] = "$field" }
        $0[.l] { $0[.last] = "$field" }
        $0[.m] { $0[.last] = (5, of: "$field") }
        $0[.n]
        {
            $0[.map] = .let("x")
            {
                $0[.input] = [0, 1, 2]
                $0[.in] = .expr { $0[.add] = ("$$x", 1) }
            }
        }
        $0[.o] { $0[.max] = (5, of: "$field") }
        $0[.p] { $0[.min] = (5, of: "$field") }
        $0[.q] { $0[.not] = "$field" }
        $0[.r] { $0[.objectToArray] = "$field" }
        $0[.s] { $0[.range] = (from: "$start", to: "$end", by: 2) }
        $0[.t] { $0[.range] = (from: "$start", to: "$end") }
        $0[.u]
        {
            $0[.reduce] = .init
            {
                $0[.input] = [0, 1, 2]
                $0[.initialValue] = 0
                $0[.in] = .expr { $0[.add] = ("$$value", "$$this") }
            }
        }
        $0[.v] { $0[.reverseArray] = "$field" }
        $0[.w] { $0[.size] = "$field" }
        $0[.x] { $0[.slice] = ("$field", distance: -5) }
        $0[.y] { $0[.slice] = ("$field", at: -2, distance: 1) }
    }

    let _:Mongo.SetDocument<Alphabet> = .init
    {
        $0[.a]
        {
            $0[.sortArray] = .init
            {
                $0[.input] = "$field"
                $0[.by, using: Mongo.AnyKeyPath.self]
                {
                    $0["x"] = (+)
                    $0["y"] = (-)
                }
            }
        }

        $0[.b]
        {
            $0[.sortArray] = .init
            {
                $0[.input] = "$field"
                $0[.by, using: Mongo.AnyKeyPath.self]
                {
                    $0["x"] = (+)
                    $0["y"] = (-)
                }
            }
        }
        $0[.c]
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", "$y")
                $0[.defaults] = [0, 0]
            }
        }
        $0[.d]
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", [1, 2])
                $0[.defaults] = [0, 0]
            }
        }
        $0[.e]
        {
            $0[.zip] = .init
            {
                $0[.inputs] = ("$x", .init
                {
                    $0[+] = 1
                    $0[+] = 2
                })
                $0[.defaults] = [0, 0]
            }
        }
    }
}
