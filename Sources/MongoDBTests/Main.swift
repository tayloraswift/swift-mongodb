import MongoDB
import NIOPosix
import Testing

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Aggregate           <ReplicatedConfiguration>.self,
        ChangeStreams       <ReplicatedConfiguration>.self,
        Collections         <ReplicatedConfiguration>.self,
        Cursors             <ReplicatedConfiguration>.self,
        Databases           <ReplicatedConfiguration>.self,
        Delete              <ReplicatedConfiguration>.self,
        Find                <ReplicatedConfiguration>.self,
        FindAndModify       <ReplicatedConfiguration>.self,
        Fsync               <ReplicatedConfiguration>.self,
        Indexes             <ReplicatedConfiguration>.self,
        Insert              <ReplicatedConfiguration>.self,
        Update              <ReplicatedConfiguration>.self,
        UpdateNested        <ReplicatedConfiguration>.self,

        Transactions        <ReplicatedConfiguration>.self,
        CausalConsistency   <ReplicatedConfigurationWithLongerTimeout>.self,

        //  Note: these tests generally fail in debug mode because it takes a long time to
        //  complete cryptographic authentication, and the driver will time out before it
        //  completes.
        Aggregate           <SingleConfiguration>.self,
        Collections         <SingleConfiguration>.self,
        Cursors             <SingleConfiguration>.self,
        Databases           <SingleConfiguration>.self,
        Delete              <SingleConfiguration>.self,
        Find                <SingleConfiguration>.self,
        FindAndModify       <SingleConfiguration>.self,
        Fsync               <SingleConfiguration>.self,
        Indexes             <SingleConfiguration>.self,
        Insert              <SingleConfiguration>.self,
        Update              <SingleConfiguration>.self,
        UpdateNested        <SingleConfiguration>.self,
    ]
}
