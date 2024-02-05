import BSON

extension Mongo.SwitchBranches
{
    @frozen public
    struct Encoder
    {
        @usableFromInline internal
        var list:BSON.ListEncoder

        @inlinable internal
        init(list:BSON.ListEncoder)
        {
            self.list = list
        }
    }
}
extension Mongo.SwitchBranches.Encoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(list: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.list.move() }

    @inlinable public static
    var type:BSON.AnyType { .list }
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
