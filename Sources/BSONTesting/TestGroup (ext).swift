import BSON
import Testing

extension TestGroup
{
    @discardableResult
    public
    func roundtrip<Codable>(_ codable:Codable,
        function:String = #function,
        file:String = #fileID,
        line:Int = #line) -> Bool
        where Codable:BSONDocumentDecodable & BSONDocumentEncodable & Equatable
    {
        let encoded:BSON.Document = .init(encoding: codable)
        let decoded:Codable? = self.do(function: function, file: file, line: line)
        {
            try .init(bson: encoded)
        }
        if  let decoded,
            let self:TestGroup = self / "Comparison"
        {
            return self.expect(decoded ==? codable)
        }
        else
        {
            return false
        }
    }
}
