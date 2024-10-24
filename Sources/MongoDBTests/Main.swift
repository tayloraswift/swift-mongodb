import MongoDB
import NIOPosix
import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Indexes             <ReplicatedConfiguration>.self,

        Transactions        <ReplicatedConfiguration>.self,


        Indexes             <SingleConfiguration>.self,
    ]
}
