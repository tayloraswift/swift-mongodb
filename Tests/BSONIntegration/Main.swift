import Testing
import BSONCanonicalization
import BSONDecoding
import BSONEncoding

@main 
enum Main:SyncTests
{
    static
    func run(tests:Tests)
    {
        do
        {
            let tests:TestGroup = tests / "enumerated-coding-keys"

            struct Codable:BSONDocumentDecodable, BSONDocumentEncodable, Equatable
            {
                enum CodingKeys:String
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

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.a = try bson[.a].decode()
                    self.b = try bson[.b].decode()
                    self.c = try bson[.c].decode()
                }

                func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
                {
                    bson[.a] = self.a
                    bson[.b] = self.b
                    bson[.c] = self.c
                }
            }

            let expected:Codable = .init(a: 5, b: [5, 6], c: [[5, 6, 7], [8]])
            let bson:BSON.Document = .init
            {
                $0["a"] = 5
                $0["b"] = [5, 6]
                $0["c"] = [[5, 6, 7], [8]]
                $0["d"] = [[[5, 6, 7, 8], [9, 10]], [[11]]]
            }

            tests.do
            {
                let original:BSON.DocumentView = .init(bson)
                let decoded:Codable = try .init(bson: original)

                tests.expect(decoded ==? expected)

                let encoded:BSON.Document = .init(with: decoded.encode(to:))

                tests.expect(true: encoded.bytes.count < original.slice.count)

                let redecoded:Codable = try .init(bson: .init(encoded)) 

                tests.expect(redecoded ==? expected)

                let reencoded:BSON.Document = .init(with: redecoded.encode(to:))

                tests.expect(reencoded.bytes ..? encoded.bytes)
            }
            
        }
    }
}
