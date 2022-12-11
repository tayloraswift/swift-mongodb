extension Mongo
{
    struct SessionContext
    {
        let id:SessionIdentifier
        let metadata:SessionMetadata
        let medium:SessionMedium

        init(id:SessionIdentifier, medium:SessionMedium, metadata:SessionMetadata)
        {
            self.id = id
            self.medium = medium
            self.metadata = metadata
        }
    }
}
