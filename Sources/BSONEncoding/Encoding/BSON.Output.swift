extension BSON.Output<[UInt8]>
{
    /// Temporarily rebinds this output’s storage buffer to an encoder of
    /// the specified type. This function does not add any headers or
    /// trailers; to emit a complete BSON frame, nest the call to this
    /// function inside a call to ``with(frame:do:)``.
    ///
    /// -   See also: ``subscript(with:)``.
    @inlinable public
    subscript<Encoder>(as _:Encoder.Type) -> Encoder where Encoder:BSONEncoder
    {
        get
        {
            .init(output: self)
        }
        _modify
        {
            var encoder:Encoder = .init(output: self)
            
            self = .init(preallocated: [])
            defer { self = encoder.output }

            yield &encoder
        }
    }
}
