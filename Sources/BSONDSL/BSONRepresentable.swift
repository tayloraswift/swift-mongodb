import BSON

public
protocol BSONRepresentable<BSONRepresentation>
{
    associatedtype BSONRepresentation

    init(_ bson:BSONRepresentation)

    var bson:BSONRepresentation { get }
}
extension BSONRepresentable<BSON.Document>
    where Self:ExpressibleByDictionaryLiteral, Key == String, Value == Never
{
    @inlinable public
    init(dictionaryLiteral:(String, Never)...)
    {
        self.init(.init())
    }
}
