import BSON
import BSONReflection
import Testing_

extension Main
{
    enum EnumeratedCodingKeys
    {
    }
}
extension Main.EnumeratedCodingKeys:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        struct Codable:BSONDocumentDecodable, BSONDocumentEncodable, Equatable
        {
            enum CodingKey:String, Sendable
            {
                case a
                case b
                case c
            }

            let a:Int
            let b:[Int]
            let c:[[Int]]

            init(a:Int, b:[Int], c:[[Int]])
            {
                self.a = a
                self.b = b
                self.c = c
            }

            init(bson:BSON.DocumentDecoder<CodingKey>)
                throws
            {
                self.a = try bson[.a].decode()
                self.b = try bson[.b].decode()
                self.c = try bson[.c].decode()
            }

            func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
            {
                bson[.a] = self.a
                bson[.b] = self.b
                bson[.c] = self.c
            }
        }

        let expected:Codable = .init(a: 5, b: [5, 6], c: [[5, 6, 7], [8]])
        let bson:BSON.Document = .init(BSON.Key.self)
        {
            $0["a"] = 5
            $0["b"] = [5, 6]
            $0["c"] = [[5, 6, 7], [8]]
            $0["d"] = [[[5, 6, 7, 8], [9, 10]], [[11]]]
        }

        tests.do
        {
            let decoded:Codable = try .init(bson: bson)

            tests.expect(decoded ==? expected)

            let encoded:BSON.Document = .init(with: decoded.encode(to:))

            tests.expect(true: encoded.bytes.count < bson.bytes.count)

            let redecoded:Codable = try .init(bson: encoded)

            tests.expect(redecoded ==? expected)

            let reencoded:BSON.Document = .init(with: redecoded.encode(to:))

            tests.expect(reencoded.bytes ..? encoded.bytes)
        }
    }
}
