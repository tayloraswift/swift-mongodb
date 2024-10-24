import MongoDB
import NIOPosix
import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Fsync               <ReplicatedConfiguration>.self,
        Indexes             <ReplicatedConfiguration>.self,

        Transactions        <ReplicatedConfiguration>.self,


        Fsync               <SingleConfiguration>.self,
        Indexes             <SingleConfiguration>.self,
    ]
}
