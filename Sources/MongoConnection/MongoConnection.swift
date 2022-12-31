import MongoChannel

@frozen public
struct MongoConnection<Metadata>
{
    public
    let metadata:Metadata
    public
    let channel:MongoChannel

    @inlinable public
    init(metadata:Metadata, channel:MongoChannel)
    {
        self.metadata = metadata
        self.channel = channel
    }
}
extension MongoConnection:Sendable where Metadata:Sendable
{
}
