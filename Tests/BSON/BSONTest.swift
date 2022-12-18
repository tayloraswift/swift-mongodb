import Base16
import BSON
import BSONUnions
import Testing

struct BSONTest
{
    let name:String
    let degenerate:String?,
        canonical:String, 
        expected:BSON.Document<[UInt8]>

    init(name:String,
        degenerate:String? = nil,
        canonical:String, 
        expected:BSON.Document<[UInt8]>)
    {
        self.name = name
        self.degenerate = degenerate
        self.canonical = canonical
        self.expected = expected
    }
}
extension BSONTest:SyncTestCase
{
    func run(tests:inout Tests)
    {
        let canonical:[UInt8] = Base16.decode(self.canonical.utf8)
        let size:Int32 = canonical.prefix(4).withUnsafeBytes
        {
            .init(littleEndian: $0.load(as: Int32.self))
        }

        let document:BSON.Document<ArraySlice<UInt8>> = .init(
            slicing: canonical.dropFirst(4).dropLast())

        tests.assert(canonical.count ==? .init(size), name: "document-encoded-header")
        tests.assert(document.header ==? size, name: "document-computed-header")

        tests.assert(self.expected ~~ document, name: "canonical-equivalence")
        tests.assert(self.expected == document, name: "binary-equivalence")

        if  let degenerate:String = self.degenerate
        {
            let degenerate:[UInt8] = Base16.decode(degenerate.utf8)
            let document:BSON.Document<ArraySlice<UInt8>> = .init(
                slicing: degenerate.dropFirst(4).dropLast())
            tests.test(name: "canonicalization")
            {
                let canonicalized:BSON.Document<ArraySlice<UInt8>> = 
                    try document.canonicalized()
                
                $0.assert(self.expected ~~ document,
                    name: "canonicalized-canonical-equivalence")
                $0.assert(self.expected == canonicalized,
                    name: "canonicalized-binary-equivalence")
            }
        }
    }
}
