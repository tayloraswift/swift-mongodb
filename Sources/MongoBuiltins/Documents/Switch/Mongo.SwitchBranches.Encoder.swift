import BSONEncoding

extension Mongo.SwitchBranches
{
    @frozen public
    struct Encoder
    {
        @usableFromInline internal
        var list:BSON.ListEncoder

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.list = .init(output: output)
        }
    }
}
extension Mongo.SwitchBranches.Encoder:BSONEncoder
{
    @inlinable public
    var output:BSON.Output<[UInt8]> { self.list.output }

    @inlinable public static
    var type:BSON { .list }
}
extension Mongo.SwitchBranches.Encoder
{
    @inlinable public mutating
    func append(_ branch:Mongo.SwitchBranch)
    {
        self.list.append(branch)
    }

    @inlinable public mutating
    func branch(with populate:(inout Mongo.SwitchBranch) throws -> ()) rethrows
    {
        self.append(try .init(with: populate))
    }
}
