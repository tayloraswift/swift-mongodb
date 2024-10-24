import MongoDB
import NIOPosix
import Testing_

@main
enum Main:TestMain
{
    static
    let all:[any TestBattery.Type] =
    [
        Transactions        <ReplicatedConfiguration>.self,
    ]
}
