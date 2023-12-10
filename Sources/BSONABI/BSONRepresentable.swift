public
protocol BSONRepresentable<BSONRepresentation>
{
    associatedtype BSONRepresentation

    init(_ bson:BSONRepresentation)

    var bson:BSONRepresentation { get }
}
