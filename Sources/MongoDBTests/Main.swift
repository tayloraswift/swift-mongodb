import MongoDB
import NIOPosix
import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        ChangeStreams       <ReplicatedConfiguration>.self,
        Collections         <ReplicatedConfiguration>.self,
        Cursors             <ReplicatedConfiguration>.self,
        Databases           <ReplicatedConfiguration>.self,
        Fsync               <ReplicatedConfiguration>.self,
        Indexes             <ReplicatedConfiguration>.self,

        Transactions        <ReplicatedConfiguration>.self,
        CausalConsistency   <ReplicatedConfigurationWithLongerTimeout>.self,

        //  Note: these tests generally fail in debug mode because it takes a long time to
        //  complete cryptographic authentication, and the driver will time out before it
        //  completes.
        Collections         <SingleConfiguration>.self,
        Cursors             <SingleConfiguration>.self,
        Databases           <SingleConfiguration>.self,
        Fsync               <SingleConfiguration>.self,
        Indexes             <SingleConfiguration>.self,
    ]
}
