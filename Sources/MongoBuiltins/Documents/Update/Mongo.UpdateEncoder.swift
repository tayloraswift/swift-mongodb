import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct UpdateEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.UpdateEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Arithmetic:String, Hashable, Sendable
    {
        case inc = "$inc"
        case mul = "$mul"
    }

    @inlinable public
    subscript(key:Arithmetic,
        yield:(inout Mongo.UpdateFieldsEncoder<Arithmetic>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Arithmetic>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Assignment:String, Sendable, Mongo.UpdateValueOperator
    {
        case set = "$set"
        case setOnInsert = "$setOnInsert"
    }

    /// We generally do not use ``BSONDocumentEncodable`` to type documents, because there are
    /// many document-typed things that do not declare a coding key type. However, in this case,
    /// we use ``BSONDocumentEncodable`` and not just ``BSONEncodable`` because you should only
    /// ever be using this with something that has a ``BSONDocumentEncodable/CodingKey``.
    @inlinable public
    subscript<Replacement>(key:Assignment) -> Replacement?
        where Replacement:BSONDocumentEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }

    @inlinable public
    subscript(key:Assignment,
        yield:(inout Mongo.UpdateFieldsEncoder<Assignment>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Assignment>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Bit:String, Sendable
    {
        case bit = "$bit"
    }

    @inlinable public
    subscript(key:Bit,
        yield:(inout Mongo.UpdateFieldsEncoder<Bit>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Bit>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum CurrentDate:String, Sendable
    {
        case currentDate = "$currentDate"
    }

    @inlinable public
    subscript(key:CurrentDate,
        yield:(inout Mongo.UpdateFieldsEncoder<CurrentDate>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<CurrentDate>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Pop:String, Sendable
    {
        case pop = "$pop"
    }

    @inlinable public
    subscript(key:Pop,
        yield:(inout Mongo.UpdateFieldsEncoder<Pop>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Pop>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Pull:String, Sendable, Mongo.UpdateValueOperator
    {
        case pull = "$pull"
    }

    @inlinable public
    subscript(key:Pull,
        yield:(inout Mongo.UpdateFieldsEncoder<Pull>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Pull>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Reduction:String, Sendable, Mongo.UpdateValueOperator
    {
        case max = "$max"
        case min = "$min"
        //  $pullAll is a reduction, it only accepts field values that form
        //  BSON lists, but we can’t represent that in our type system.
        case pullAll = "$pullAll"
    }

    @inlinable public
    subscript(key:Reduction,
        yield:(inout Mongo.UpdateFieldsEncoder<Reduction>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Reduction>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum Rename:String, Sendable
    {
        case rename = "$rename"
    }

    @inlinable public
    subscript(key:Rename,
        yield:(inout Mongo.UpdateFieldsEncoder<Rename>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Rename>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    @frozen public
    enum ArrayUnion:String, Sendable, Mongo.UpdateValueOperator
    {
        case addToSet = "$addToSet"
        case push = "$push"
    }

    @inlinable public
    subscript(key:ArrayUnion,
        yield:(inout Mongo.UpdateFieldsEncoder<ArrayUnion>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<ArrayUnion>.self])
        }
    }
}
extension Mongo.UpdateEncoder
{
    /// Takes a document and removes the specified fields.
    /// Not to be confused with the ``Mongo.PipelineEncoder.Unset/unset``
    /// aggregation pipeline stage, which can take a field path directly.
    @frozen public
    enum Unset:String, Sendable
    {
        case unset = "$unset"
    }

    @inlinable public
    subscript(key:Unset,
        yield:(inout Mongo.UpdateFieldsEncoder<Unset>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Unset>.self])
        }
    }
}
