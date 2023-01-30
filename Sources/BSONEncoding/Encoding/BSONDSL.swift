extension BSONDSL
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
extension BSONDSL
{
    /// Appends the given key-value pair to this document builder as a field
    /// by accessing the value’s ``BSONEncodable.bson`` property witness, if
    /// it is not [`nil`]() and is not empty (or `elide` is [`false`]()), does
    /// nothing otherwise. The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() assignment to this subscript (including mutations
    /// that leave the value in a non-[`nil`]() state after returning) will add
    /// a new field to the document intermediate, even if the key is the same.
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
    /// Appends the given key-value pair to this list of fields by delegating
    /// to the value’s ``BSONEncodable.encode(to:)`` witness, if it is not
    /// [`nil`](); does nothing otherwise. The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() assignment to this subscript (including mutations
    /// that leave the value in a non-[`nil`]() state after returning) will add
    /// a new field to the document intermediate, even if the key is the same.
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
    @inlinable public
    subscript(key:String) -> Void?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let _:Void = value
            {
                self.append(key: key) { $0.encode(null: ()) }
            }
        }
    }
}
extension BSONDSL
{
    @inlinable public
    subscript(key:String, elide elide:Bool = false) -> BSON.Elements<Self>?
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
}
extension BSONDSL where Subdocument:BSONEncodable
{
    @inlinable public
    subscript(key:String, elide elide:Bool = false) -> Subdocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Subdocument, !(elide && value.isEmpty)
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
