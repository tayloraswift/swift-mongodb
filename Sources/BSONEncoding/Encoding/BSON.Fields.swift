extension BSON.Fields
{
    @inlinable public
    init<Encodable>(fields:some Sequence<(key:String, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init
        {
            for (key, value):(String, Encodable) in fields
            {
                $0.append(key: key, with: value.encode(to:))
            }
        }
    }
}
extension BSON.Fields
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// given tuple elements as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``BSON.Elements`` API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript(key:String, elide elide:Bool) -> BSON.Elements<Self>?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:BSON.Elements<Self>, !(elide && value.isEmpty)
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }

    /// Appends the given key-value pair to this document builder, encoding the
    /// given subdocument as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``Subdocument`` DSL API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript(key:String, elide elide:Bool) -> Self?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Self, !(elide && value.isEmpty)
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }

    /// Appends a key-value pair to this document builder, encoding a
    /// subdocument of a foreign DSL type as the field value.
    ///
    /// Type inference will always prefer the concrete ``Subdocument``-typed
    /// subscript overload over this one. This means that only API belonging to
    /// the ``Subdocument`` DSL will be available with leading-dot syntax.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript<Encodable>(key:String, elide elide:Bool) -> Encodable?
        where Encodable:BSONEncodable & BSONDSL
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable, !(elide && value.isEmpty)
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
    /// Appends the given key-value pair to this document builder, encoding the
    /// given collection as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript<Encodable>(key:String, elide elide:Bool) -> Encodable?
        where Encodable:BSONEncodable & Collection
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable, !(elide && value.isEmpty)
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
    /// Appends the given key-value pair to this document builder, encoding the
    /// value as the field value using its ``BSONEncodable`` implementation.
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() assignment to this subscript (including mutations
    /// that leave the value in a non-[`nil`]() state after returning) will add
    /// a new field to the document, even if the key is the same.
    @inlinable public
    subscript<Encodable>(key:String) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
extension BSON.Fields?
{
    @inlinable public
    init(with populate:(inout BSON.Fields) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
extension BSON.Elements<BSON.Fields>?
{
    @inlinable public
    init(with populate:(inout BSON.Elements<BSON.Fields>) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
