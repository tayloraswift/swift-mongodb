import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct FacetEncoder<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<CodingKey>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<CodingKey>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.FacetEncoder:BSON.Encoder
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

extension Mongo.FacetEncoder
{
    @available(*, unavailable)
    @inlinable public
    subscript(key:CodingKey) -> Mongo.Pipeline? { nil }

    @inlinable public
    subscript(key:CodingKey, yield:(inout Mongo.PipelineEncoder) -> () = { _ in }) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.PipelineEncoder.self])
        }
    }

    @inlinable public
    subscript<Pipeline>(key:CodingKey) -> Pipeline? where Pipeline:Mongo.PipelineEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Pipeline
            {
                self[key] { $0 += value }
            }
        }
    }
}
