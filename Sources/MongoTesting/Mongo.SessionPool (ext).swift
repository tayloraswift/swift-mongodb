import MongoDB

extension Mongo.SessionPool
{
    /// Sets up a temporary database with the specified name, removing it after
    /// the closure argument returns. If a database with the specified name
    /// already exists, this function *drops* it before calling the closure.
    ///
    /// >   Note:
    ///     MongoDB database creation is lazy, generally MongoDB servers will
    ///     not actually create a database until you run a command that
    ///     references it.
    public
    func withTemporaryDatabase(_ database:Mongo.Database,
        run body:() async throws -> ()) async throws
    {
        //  if we already have a database with this name, drop it.
        try await self.run(command: Mongo.DropDatabase.init(), against: database)

        let before:Set<Mongo.Database> = .init(try await self.run(
            command: Mongo.ListDatabases.NameOnly.init(),
            against: .admin))

        try await body()

        try await self.run(command: Mongo.DropDatabase.init(), against: database)

        let after:Set<Mongo.Database> = .init(try await self.run(
            command: Mongo.ListDatabases.NameOnly.init(),
            against: .admin))

        guard before == after
        else
        {
            fatalError("failed to remove temporary database '\(database)'")
        }
    }
}
