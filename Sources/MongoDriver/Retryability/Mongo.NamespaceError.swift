extension Mongo
{
    @available(*, deprecated, message: """
        This type no longer functions properly; \
        clients should check for ServerError(26) instead.
        """)
    @frozen public
    struct NamespaceError:Equatable, Error
    {
    }
}
