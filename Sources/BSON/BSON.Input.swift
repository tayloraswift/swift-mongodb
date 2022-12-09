import BSONTraversal

extension BSON
{
    /// A type for managing BSON parsing state. Most users of this module
    /// should not need to interact with it directly.
    @frozen public
    struct Input<Source> where Source:RandomAccessCollection<UInt8>
    {
        public
        let source:Source
        public
        var index:Source.Index

        /// Creates a parsing input view over the given `source` data,
        /// and initializes its ``index`` to the start index of the `source`.
        @inlinable public
        init(_ source:Source)
        {
            self.source = source
            self.index = self.source.startIndex
        }
    }
}
extension BSON.Input:Sendable where Source:Sendable, Source.Index:Sendable
{
}
extension BSON.Input
{
    /// Consumes and returns a single byte from this parsing input.
    @inlinable public mutating
    func next() -> UInt8?
    {
        guard self.index < self.source.endIndex
        else
        {
            return nil
        }
        defer
        {
            self.source.formIndex(after: &self.index)
        }
        
        return self.source[self.index]
    }
    /// Advances the current index until encountering the specified `byte`.
    /// After this method returns, ``index`` points to the byte after
    /// the matched byte.
    ///
    /// -   Returns:
    ///         A range covering the bytes skipped. The upper-bound of
    ///         the range points to the matched byte.
    @discardableResult
    @inlinable public mutating
    func parse(through byte:UInt8) throws -> Range<Source.Index>
    {
        let start:Source.Index = self.index
        while self.index < self.source.endIndex
        {
            defer
            {
                self.source.formIndex(after: &self.index)
            }
            if  self.source[self.index] == byte
            {
                return start ..< self.index
            }
        }
        throw BSON.InputError.init(expected: .byte(byte))
    }
    /// Parses a null-terminated string.
    @inlinable public mutating
    func parse(as _:String.Type = String.self) throws -> String
    {
        .init(decoding: self.source[try self.parse(through: 0x00)], as: Unicode.UTF8.self)
    }
    /// Parses a MongoDB object reference.
    @inlinable public mutating
    func parse(as _:BSON.Identifier.Type = BSON.Identifier.self) throws -> BSON.Identifier
    {
        let start:Source.Index = self.index
        if  let end:Source.Index = self.source.index(self.index, offsetBy: 12, 
                limitedBy: self.source.endIndex)
        {
            self.index = end
            return withUnsafeTemporaryAllocation(byteCount: 12,
                alignment: MemoryLayout<UInt32>.alignment)
            {
                $0.copyBytes(from: self.source[start ..< end])
                return .init(bitPattern: $0.load(as: (UInt32, UInt32, UInt32).self))
            }
        }
        else
        {
            throw self.expected(.bytes(12))
        }
    }
    /// Parses a boolean.
    @inlinable public mutating
    func parse(as _:Bool.Type = Bool.self) throws -> Bool
    {
        switch self.next()
        {
        case 0?:
            return false
        case 1?:
            return true
        case let code?:
            throw BSON.BooleanSubtypeError.init(invalid: code)
        case nil:
            throw BSON.InputError.init(expected: .bytes(1))
        }
    }
    @inlinable public mutating
    func parse(as _:BSON.Decimal128.Type = BSON.Decimal128.self) throws -> BSON.Decimal128
    {
        let low:UInt64 = try self.parse(as: UInt64.self)
        let high:UInt64 = try self.parse(as: UInt64.self)
        return .init(high: high, low: low)
    }
    @inlinable public mutating
    func parse(as _:BSON.Millisecond.Type = BSON.Millisecond.self) throws -> BSON.Millisecond
    {
        .init(try self.parse(as: Int64.self))
    }
    @inlinable public mutating
    func parse(as _:BSON.Regex.Type = BSON.Regex.self) throws -> BSON.Regex
    {
        let pattern:String = try self.parse(as: String.self)
        let options:String = try self.parse(as: String.self)
        return try .init(pattern: pattern, options: options)
    }
    /// Parses a little-endian integer.
    @inlinable public mutating
    func parse<LittleEndian>(as _:LittleEndian.Type = LittleEndian.self) throws -> LittleEndian
        where LittleEndian:FixedWidthInteger
    {
        let start:Source.Index = self.index
        if  let end:Source.Index = self.source.index(self.index, 
                offsetBy: MemoryLayout<LittleEndian>.size, 
                limitedBy: self.source.endIndex)
        {
            self.index = end
            return withUnsafeTemporaryAllocation(
                byteCount: MemoryLayout<LittleEndian>.size,
                alignment: MemoryLayout<LittleEndian>.alignment)
            {
                $0.copyBytes(from: self.source[start ..< end])
                return .init(littleEndian: $0.load(as: LittleEndian.self))
            }
        }
        else
        {
            throw self.expected(.bytes(MemoryLayout<LittleEndian>.size))
        }
    }
    /// Parses a traversable BSON element. The output is typically opaque,
    /// which allows decoders to skip over regions of a BSON document.
    @inlinable public mutating
    func parse<View>(as _:View.Type = View.self) throws -> View
        where View:VariableLengthBSON<Source.SubSequence>
    {
        let header:Int = .init(try self.parse(as: Int32.self))
        let stride:Int = header - View.Frame.prefix
        let count:Int = stride - View.Frame.suffix
        if  count < 0
        {
            throw BSON.HeaderError<View.Frame>.init(length: header)
        }
        let start:Source.Index = self.index
        if  let end:Source.Index = self.source.index(start, offsetBy: stride, 
                limitedBy: self.source.endIndex)
        {
            self.index = end
            return try .init(
                slicing: self.source[start ..< self.source.index(start, offsetBy: count)])
        }
        else
        {
            throw self.expected(.bytes(stride))
        }
    }
    
    /// Asserts that there is no input remaining.
    @inlinable public
    func finish() throws
    {
        if self.index != self.source.endIndex
        {
            throw self.expected(.end)
        }
    }

    /// Creates an ``InputError`` with appropriate context for the specified expectation.
    @inlinable public
    func expected(_ expectation:BSON.InputError.Expectation) -> BSON.InputError
    {
        .init(expected: expectation,
            encountered: self.source.distance(from: self.index, to: self.source.endIndex))
    }
}
