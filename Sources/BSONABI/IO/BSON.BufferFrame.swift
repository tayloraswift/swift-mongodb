extension BSON
{
    /// A type that augments a ``BufferFrameType`` conformance with a BSON metatype value. This
    /// is a derived protocol because it is sometimes useful to repurpose the BSON frame parsing
    /// machinery for additional (fictional) frame types that never appear in BSON data.
    public
    protocol BufferFrame:BufferFrameType
    {
        /// The BSON metatype value this buffer frame is associated with.
        var type:AnyType { get }
    }
}
