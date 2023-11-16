import MongoDB

extension Mongo.SessionPool
{
    /// Sets up a temporary database with the specified name, removing it after the closure
    /// argument returns. If a database with the specified name already exists, this function
    /// *drops* it before calling the closure.
    ///
    /// It is good practice to give scratch databases names that start with an uppercase letter.
    /// To prevent accidental deletion of long-lived databases, this function always traps if
    /// the database name begins with a lowercase letter.
    ///
    /// >   Note:
    ///     MongoDB database creation is lazy, generally MongoDB servers will
    ///     not actually create a database until you run a command that
    ///     references it.
    public nonisolated
    func withTemporaryDatabase(_ database:Mongo.Database,
        run body:() async throws -> ()) async throws
    {
        guard case true? = database.name.first?.isUppercase
        else
        {
            fatalError("""
                scratch database names must start with an uppercase letter to prevent accidental
                deletion of long-lived databases!
                """)
        }
        //  If we already have a database with this name, drop it. This often happens if tests
        //  crash midway through.
        try await self.run(command: Mongo.DropDatabase.init(), against: database)

        let before:Set<Mongo.Database> = .init(try await self.run(
            command: Mongo.ListDatabases.NameOnly.init(),
            against: .admin))

        if  before.contains(database)
        {
            fatalError("""
                failed to remove pre-existing database '\(database)', it is possible this test
                is running in parallel with another test using the same database name!
                """)
        }

        try await body()

        try await self.run(command: Mongo.DropDatabase.init(), against: database)

        let after:Set<Mongo.Database> = .init(try await self.run(
            command: Mongo.ListDatabases.NameOnly.init(),
            against: .admin))

        //  We cannot assert equivalence of `before` and `after` because `body` might set up
        //  additional databases.
        if  after.contains(database)
        {
            fatalError("""
                failed to remove temporary database '\(database)', it is possible this test
                is running in parallel with another test using the same database name!
                """)
        }
    }
}
