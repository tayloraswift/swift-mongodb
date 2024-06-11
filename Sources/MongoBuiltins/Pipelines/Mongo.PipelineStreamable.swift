extension Mongo
{
    public
    protocol PipelineStreamable
    {
        static
        func += (pipeline:inout Mongo.PipelineEncoder, self:Self)
    }
}
