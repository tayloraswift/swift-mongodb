/// An error type that supports printing with a custom heading.
public 
protocol NamedError:CustomStringConvertible, Error 
{
    /// The heading to print instead of this error’s type identifier.
    var name:String { get }
    var message:String { get }
}
extension NamedError
{
    public
    var description:String
    {
        "\(Self.bold(Self.color("\(self.name):"))) \(self.message)"
    }
}
