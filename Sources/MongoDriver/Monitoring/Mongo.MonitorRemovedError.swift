extension Mongo
{
    public
    struct MonitorRemovedError:Error
    {
        public
        let reason:(any Error)?

        public
        init(because reason:(any Error)? = nil)
        {
            self.reason = reason
        }
    }
}
