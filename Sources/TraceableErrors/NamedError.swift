/// An error type that supports printing with a custom heading.
public 
protocol NamedError:CustomStringConvertible, Error 
{
    /// The heading to print instead of this error’s type identifier.
    var name:String { get }
}
