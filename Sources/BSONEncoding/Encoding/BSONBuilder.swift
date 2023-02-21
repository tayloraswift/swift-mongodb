public
protocol BSONBuilder<CodingKey>
{
    associatedtype CodingKey

    mutating
    func append(_ key:CodingKey, _ value:some BSONDSLEncodable)
}

extension BSONBuilder
{
    @inlinable public mutating
    func push(_ key:CodingKey, _ value:(some BSONDSLEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }

    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:CodingKey, _ value:some BSONDSLEncodable)
    {
        self.push(key, value as _?)
    }
}
extension BSONBuilder<String>
{
    @inlinable public mutating
    func append(_ key:some RawRepresentable<String>, _ value:some BSONDSLEncodable)
    {
        self.append(key.rawValue, value)
    }
    @inlinable public mutating
    func push(_ key:some RawRepresentable<String>, _ value:(some BSONDSLEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }

    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:some RawRepresentable<String>, _ value:some BSONDSLEncodable)
    {
        self.push(key, value as _?)
    }
}
extension BSONBuilder<String>
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// given list elements as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``BSON.List`` API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript(key:some RawRepresentable<String>, elide elide:Bool = false) -> BSON.List<Self>?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:BSON.List<Self>, !(elide && value.isEmpty)
            {
                self.append(key.rawValue, value)
            }
        }
    }
}
extension BSONBuilder
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// given list elements as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``BSON.List`` API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript(key:CodingKey, elide elide:Bool = false) -> BSON.List<Self>?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:BSON.List<Self>, !(elide && value.isEmpty)
            {
                self.append(key, value)
            }
        }
    }
    /// Appends the given key-value pair to this document builder, encoding the
    /// given subdocument as the field value, so long as it is not empty (or
    /// `elide` is [`false`]()).
    ///
    /// Type inference will always infer this subscript as long as any
    /// ``Document`` DSL API is used within its builder closure.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript(key:CodingKey, elide elide:Bool = false) -> BSON.Document?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:BSON.Document, !(elide && value.isEmpty)
            {
                self.append(key, value)
            }
        }
    }

    /// Appends a key-value pair to this document builder, encoding a
    /// subdocument of a foreign DSL type as the field value.
    ///
    /// Type inference will always prefer the concrete [`Self`]()-typed
    /// subscript overload over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() and non-elided assignment to this subscript
    /// (including mutations that leave the value in a non-[`nil`]() and
    /// non-elided state after returning) will add a new field to the document,
    /// even if the key is the same.
    @inlinable public
    subscript<Encodable>(key:CodingKey, elide elide:Bool = false) -> Encodable?
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
                self.append(key, value)
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
    subscript<Encodable>(key:CodingKey, elide elide:Bool) -> Encodable?
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
                self.append(key, value)
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
    subscript<Value>(key:CodingKey) -> Value?
        where Value:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.push(key, value)
        }
    }
}
