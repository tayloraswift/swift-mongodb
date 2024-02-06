import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct UpdateDocumentEncoder:Sendable
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
extension Mongo.UpdateDocumentEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension Mongo.UpdateDocumentEncoder
{
    @inlinable public
    subscript(key:Arithmetic,
        yield:(inout Mongo.UpdateFieldsEncoder<Arithmetic>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Arithmetic>.self])
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

    @inlinable public
    subscript(key:Bit,
        yield:(inout Mongo.UpdateFieldsEncoder<Bit>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Bit>.self])
        }
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

    @inlinable public
    subscript(key:Pop,
        yield:(inout Mongo.UpdateFieldsEncoder<Pop>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Pop>.self])
        }
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

    @inlinable public
    subscript(key:Reduction,
        yield:(inout Mongo.UpdateFieldsEncoder<Reduction>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.UpdateFieldsEncoder<Reduction>.self])
        }
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

@available(*, deprecated, message: "Use the functional subscripts instead.")
extension Mongo.UpdateDocumentEncoder
{
    @inlinable public
    subscript(key:Arithmetic) -> Mongo.UpdateFields<Arithmetic>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }

    @inlinable public
    subscript(key:Bit) -> Mongo.UpdateFields<Bit>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript(key:CurrentDate) -> Mongo.UpdateFields<CurrentDate>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript(key:Pop) -> Mongo.UpdateFields<Pop>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript(key:Pull) -> Mongo.UpdateFields<Pull>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }

    @inlinable public
    subscript(key:Reduction) -> Mongo.UpdateFields<Reduction>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }

    @inlinable public
    subscript(key:Rename) -> Mongo.UpdateFields<Rename>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript(key:Unset) -> Mongo.UpdateFields<Unset>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
