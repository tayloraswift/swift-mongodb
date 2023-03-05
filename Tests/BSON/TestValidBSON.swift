import Base16
import BSON
import BSONCanonicalization
import Testing

func TestValidBSON(_ tests:TestGroup?,
    degenerate:String? = nil,
    canonical:String, 
    expected:BSON.DocumentView<[UInt8]>)
{
    guard let tests:TestGroup
    else
    {
        return
    }

    let canonical:[UInt8] = Base16.decode(canonical.utf8)
    let size:Int32 = canonical.prefix(4).withUnsafeBytes
    {
        .init(littleEndian: $0.load(as: Int32.self))
    }

    let document:BSON.DocumentView<ArraySlice<UInt8>> = .init(
        slicing: canonical.dropFirst(4).dropLast())

    tests.expect(canonical.count ==? .init(size))
    tests.expect(document.header ==? size)

    tests.expect(true: expected ~~ document)
    tests.expect(true: expected == document)

    if  let degenerate:String
    {
        let degenerate:[UInt8] = Base16.decode(degenerate.utf8)
        let document:BSON.DocumentView<ArraySlice<UInt8>> = .init(
            slicing: degenerate.dropFirst(4).dropLast())
        
        (tests / "canonicalization")?.do
        {
            let canonicalized:BSON.DocumentView<ArraySlice<UInt8>> = 
                try document.canonicalized()
            
            tests.expect(true: expected ~~ document)
            tests.expect(true: expected == canonicalized)
        }
    }
}
