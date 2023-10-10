import TraceableErrors

extension Mongo
{
    @frozen public
    struct NamespaceError:Equatable, Error
    {
        @inlinable public
        init()
        {
        }
    }
}
extension Mongo.NamespaceError:NamedError
{
    public
    var name:String { "NamespaceError" }

    public
    var message:String
    {
        "namespace does not exist"
    }
}
