import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortDocument:MongoDocumentDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.SortDocument
{
    @available(*, unavailable,
        message: "pass the `(+)` or `(-)` operator functions to specify sort direction.")
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Int?
    {
        get
        {
            nil
        }
        set
        {
        }
    }
}
extension Mongo.SortDocument
{
    @inlinable public
    subscript(natural:Natural) -> ((Mongo.SortAscending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                self.bson.append(natural, 1 as Int32)
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> ((Mongo.SortAscending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                self.bson.append(path.stem, 1 as Int32)
            }
        }
    }

    @inlinable public
    subscript(natural:Natural) -> ((Mongo.SortDescending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                self.bson.append(natural, -1 as Int32)
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> ((Mongo.SortDescending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                self.bson.append(path.stem, -1 as Int32)
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.SortOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
