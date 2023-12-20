/// A type that serves as a master coding model for a type of document in a MongoDB
/// collection.
///
/// In many database applications, a single type of document can have many projected
/// representations. A master coding model is a type that defines the full set of
/// coding keys used to encode the documents.
public
protocol MongoMasterCodingModel<CodingKey>
{
    associatedtype CodingKey:RawRepresentable<String>
}
extension MongoMasterCodingModel
{
    @inlinable public static
    subscript(key:CodingKey) -> Mongo.KeyPath
    {
        .init(rawValue: key.rawValue)
    }
}
