import BSONEncoding

extension MongoExpression
{
    @inlinable public
    subscript(key:Filter) -> Mongo.FilterDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:Map) -> Mongo.MapDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:Reduce) -> Mongo.ReduceDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:SortArray) -> Mongo.SortArrayDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:Zip) -> Mongo.ZipDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
}
extension MongoExpression
{
    @inlinable public
    subscript<Sequence, Element, Start, End>(
        key:Index) -> (in:Sequence?, of:Element?, from:Start?, to:End?)
        where   Sequence:MongoExpressionEncodable,
                Element:MongoExpressionEncodable,
                Start:MongoExpressionEncodable,
                End:MongoExpressionEncodable
    {
        get
        {
            (in: nil, of: nil, from: nil, to: nil)
        }
        set(value)
        {
            if case (in: let sequence?, of: let element?, let start, let end) = value
            {
                self.document.append(key)
                {
                    $0.append(sequence)
                    $0.append(element)
                    
                    if let start:Start
                    {
                        $0.append(start)
                        $0.push(end)
                    }
                }
            }
        }
    }
    @inlinable public
    subscript<Sequence, Element>(key:Index) -> (in:Sequence?, of:Element?)
        where   Sequence:MongoExpressionEncodable,
                Element:MongoExpressionEncodable
    {
        get
        {
            (in: nil, of: nil)
        }
        set(value)
        {
            self[key] = (value.0, value.1, nil as Never?, nil as Never?)
        }
    }
}
