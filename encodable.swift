protocol BSONEncodable
{
}

extension Int:BSONEncodable
{
}
extension String:BSONEncodable
{
}
extension Optional:BSONEncodable where Wrapped:BSONEncodable
{
}

protocol BSONDSL
{
    init()
}
struct UniversalBSONDSL:BSONDSL
{
    init()
    {
    }
}
extension UniversalBSONDSL:BSONEncodable
{
}
extension UniversalBSONDSL
{
    subscript<First, Second>(key:String) -> (First?, Second?)
        where First:BSONEncodable, Second:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            fatalError()
        }
    }
    subscript<Encodable>(key:String) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            fatalError()
        }
    }
}

// extension BSONEncodable where Self == UniversalBSONDSL
// {
//     init(with populate:(inout Self.Encoder) throws -> ()) rethrows
//     {
//         self.init()
//         try populate(&self)
//     }
// }
extension BSONDSL
{
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
extension UniversalBSONDSL?
{
    init(with populate:(inout Wrapped) throws -> ()) rethrows where Wrapped:BSONDSL
    {
        self = .some(try .init(with: populate))
    }
}

func test()
{
    let bson:UniversalBSONDSL = .init
    {
        $0["$abs"] = 1
        $0["$add"] = (1, "$field")

        // $0["$add"] = (0, .init
        // {
        //     _ in
        // })
        $0["$add"] = (1, .init
        {
            $0["x"] = 1
        })

        // $0["$add"] = (1, .document
        // {
        //     $0["$abs"] = 1
        // })

        $0["$add"] = (1, .init
        {
            $0["x"] = 1
            $0["x"] = 1
        })

        $0["$add"] = (1, .init
        {
            $0["x"] = 1
        })

        // $0["$abs"] = .document
        // {
        //     _ in
        // }
    }
}
