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
        let bytes:Bytes

        @inlinable public
        init(bytes:Bytes)
        {
            self.bytes = bytes
        }
    }
}
extension BSON.UTF8View:Sendable where Bytes:Sendable
{
}
extension BSON.UTF8View<ArraySlice<UInt8>>:BSON.FrameTraversable
{
    public
    typealias Frame = BSON.UTF8Frame

    /// Stores the argument in ``bytes`` unchanged. Equivalent to ``init(bytes:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:Bytes) throws
    {
        self.init(bytes: bytes)
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
        self.init(bytes: .init(string.utf8))
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
        self.init(bytes: string.utf8)
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
        self.init(bytes: string.utf8)
    }
}
extension BSON.UTF8View<ArraySlice<UInt8>>
{
    /// Creates a BSON UTF-8 string backed by a `[UInt8]` array slice, by copying
    /// the UTF-8 code units stored in the given static string.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the length of the string.
    @inlinable public
    init(_ string:StaticString)
    {
        self.init(bytes: string.withUTF8Buffer(ArraySlice<UInt8>.init(_:)))
    }
}

extension BSON.UTF8View:CustomStringConvertible
{
    /// Copies and validates the backing storage of the given UTF-8 string to a
    /// native Swift string, repairing invalid code units if needed.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public
    var description:String
    {
        .init(decoding: self.bytes, as: Unicode.UTF8.self)
    }
}
extension BSON.UTF8View
{
    /// The length that would be encoded in this string’s prefixed header.
    /// Equal to [`self.slice.count + 1`]().
    @inlinable public
    var header:Int32
    {
        Int32.init(self.bytes.count) + 1
    }
    /// The size of this string when encoded with its header and trailing null byte.
    /// This is *not* the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.bytes.count
    }
}

extension BSON.UTF8View
{
    @available(*, deprecated, renamed: "init(bytes:)")
    @inlinable public
    init(slice:Bytes)
    {
        self.init(bytes: slice)
    }
}
