extension BSON.Regex:BSONDecodable
{
    /// Attempts to unwrap a ``BSON/Regex`` from the given variant.
    /// The library always eagerly-parses regexes, so this initializer
    /// does not perform any copying.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
