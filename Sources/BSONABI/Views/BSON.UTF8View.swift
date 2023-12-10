extension BSON
{
    /// A BSON UTF-8 string. This string is allowed to contain null bytes.
    ///
    /// This type can wrap potentially-invalid UTF-8 data, therefore it
    /// is not backed by an instance of ``String``. Moreover, it (and not ``String``)
    /// is the payload of ``BSON/AnyValue.string(_:)`` to ensure that long string
    /// fields can be traversed in constant time.
    ///
    /// To convert a UTF-8 string to a native Swift ``String`` (repairing invalid UTF-8),
    /// use the ``description`` property.
    @frozen public
    struct UTF8View<Bytes> where Bytes:BidirectionalCollection<UInt8>
    {
        /// The UTF-8 code units backing this string. This collection does *not*
        /// include the trailing null byte that typically appears when this value
        /// occurs inline in a document.
        public
        let slice:Bytes

        @inlinable public
        init(slice:Bytes)
        {
            self.slice = slice
        }
    }
}
extension BSON.UTF8View where Bytes:RangeReplaceableCollection
{
    /// Creates a BSON UTF-8 string by copying the UTF-8 code units of
    /// the given string to dedicated backing storage.
    /// When possible, prefer using a specialization of this type where
    /// `Bytes` is `String.UTF8View` or `Substring.UTF8View`, because
    /// instances of those specializations can be constructed as
    /// copy-less collection views.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the length of the string.
    @inlinable public
    init(from string:some StringProtocol)
    {
        self.init(slice: .init(string.utf8))
    }
}
extension BSON.UTF8View<String.UTF8View>:ExpressibleByStringLiteral,
    ExpressibleByExtendedGraphemeClusterLiteral,
    ExpressibleByUnicodeScalarLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)
    }

    /// Creates a BSON UTF-8 string backed by a ``String.UTF8View``, making
    /// the base string contiguous, if it is not already.
    ///
    /// >   Complexity:
    ///     O(1) if the string is already a contiguous UTF-8 string;
    ///     otherwise O(*n*), where *n* is the length of the string.
    @inlinable public
    init(_ string:String)
    {
        var string:String = string
            string.makeContiguousUTF8()
        self.init(slice: string.utf8)
    }
}
extension BSON.UTF8View<Substring.UTF8View>
{
    /// Creates a BSON UTF-8 string backed by a ``Substring.UTF8View``, making
    /// the base substring contiguous, if it is not already.
    ///
    /// >   Complexity:
    ///     O(1) if the substring is already a contiguous UTF-8 substring;
    ///     otherwise O(*n*), where *n* is the length of the substring.
    @inlinable public
    init(_ string:Substring)
    {
        var string:Substring = string
            string.makeContiguousUTF8()
        self.init(slice: string.utf8)
    }
}
extension BSON.UTF8View<[UInt8]>
{
    /// Creates a BSON UTF-8 string backed by a `[UInt8]` array, by copying
    /// the UTF-8 code units stored in the given static string.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the length of the string.
    @inlinable public
    init(_ string:StaticString)
    {
        self.init(slice: string.withUTF8Buffer([UInt8].init(_:)))
    }
}
extension BSON.UTF8View:Equatable
{
    /// Performs a unicode-aware string comparison on two UTF-8 strings.
    @inlinable public static
    func == (lhs:Self, rhs:BSON.UTF8View<some BidirectionalCollection<UInt8>>) -> Bool
    {
        lhs.description == rhs.description
    }
}
extension BSON.UTF8View:Sendable where Bytes:Sendable
{
}

extension BSON.UTF8View:CustomStringConvertible
{
    /// Equivalent to calling ``String.init(bson:)`` on this instance.
    @inlinable public
    var description:String
    {
        .init(bson: self)
    }
}
extension BSON.UTF8View:BSON.FrameTraversable where Bytes:RandomAccessCollection<UInt8>
{
    public
    typealias Frame = BSON.UTF8Frame

    /// Stores the argument in ``slice`` unchanged. Equivalent to ``init(slice:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:Bytes) throws
    {
        self.init(slice: bytes)
    }
}
extension BSON.UTF8View:BSON.FrameView where Bytes:RandomAccessCollection<UInt8>
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.utf8)
    }
}
extension BSON.UTF8View
{
    /// The length that would be encoded in this string’s prefixed header.
    /// Equal to [`self.slice.count + 1`]().
    @inlinable public
    var header:Int32
    {
        Int32.init(self.slice.count) + 1
    }
    /// The size of this string when encoded with its header and trailing null byte.
    /// This is *not* the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.slice.count
    }
}

extension String
{
    /// Copies and validates the backing storage of the given UTF-8 string to a
    /// native Swift string, repairing invalid code units if needed.
    ///
    /// This is the preferred way to get the string value of a UTF-8 string.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public
    init(bson:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.init(decoding: bson.slice, as: Unicode.UTF8.self)
    }
}
