extension Mongo.ReadConcern
{
    var level:Level
    {
        .ratification(self)
    }
}
