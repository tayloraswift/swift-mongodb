import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LookupEncoder:Sendable
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
extension Mongo.LookupEncoder:BSON.Encoder
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
extension Mongo.LookupEncoder
{
    @frozen public
    enum Field:String, Hashable, Sendable
    {
        case `as`
        case localField
        case foreignField
    }

    @inlinable public
    subscript(key:Field) -> Mongo.AnyKeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            //  Value does not include leading dollar sign!
            value?.stem.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.LookupEncoder
{
    @frozen public
    enum From:String, Hashable, Sendable
    {
        case from
    }

    @inlinable public
    subscript(key:From) -> Mongo.Collection?
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
extension Mongo.LookupEncoder
{
    @frozen public
    enum Let:String, Sendable
    {
        case `let`
    }

    @inlinable public
    subscript(key:Let, yield:(inout Mongo.LetEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.LetEncoder.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        nil
    }
}
extension Mongo.LookupEncoder
{
    @frozen public
    enum Pipeline:String, Hashable, Sendable
    {
        case pipeline
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Pipeline) -> Mongo.Pipeline? { nil }

    @inlinable public
    subscript(key:Pipeline, yield:(inout Mongo.PipelineEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.PipelineEncoder.self])
        }
    }

    @inlinable public
    subscript<Encodable>(key:Pipeline) -> Encodable? where Encodable:Mongo.PipelineEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Encodable
            {
                self[key] { $0 += value }
            }
        }
    }
}
