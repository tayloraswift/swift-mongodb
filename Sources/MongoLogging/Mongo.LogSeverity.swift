import Atomics

extension Mongo
{
    @frozen public
    enum LogSeverity:UInt8, Sendable
    {
        case debug
        case error

        /// No log events use this level. Using this as a logging level effectively disables
        /// logging entirely.
        case fatal
    }
}
extension Mongo.LogSeverity:AtomicValue
{
}
extension Mongo.LogSeverity:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
