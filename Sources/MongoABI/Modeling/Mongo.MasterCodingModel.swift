@available(*, deprecated, renamed: "Mongo.MasterCodingModel")
public
typealias MongoMasterCodingModel = Mongo.MasterCodingModel

extension Mongo
{
    /// A type that serves as a master coding model for a type of document in a MongoDB
    /// collection.
    ///
    /// In many database applications, a single type of document can have many projected
    /// representations. A master coding model is a type that defines the full set of
    /// coding keys used to encode the documents.
    ///
    /// Occasionally, a master coding model shares a ``CodingKey`` type with a
    /// ``MasterCodingDelta`` type.
    public
    protocol MasterCodingModel<CodingKey>
    {
        associatedtype CodingKey:RawRepresentable<String>
    }
}
extension Mongo.MasterCodingModel
{
    @inlinable public static
    subscript(key:CodingKey) -> Mongo.AnyKeyPath
    {
        .init(rawValue: key.rawValue)
    }
}
