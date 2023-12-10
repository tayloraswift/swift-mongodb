import BSON

extension Mongo
{
    @frozen public
    struct Collation:Sendable
    {
        public
        let locale:String

        public
        let alternate:Alternate?
        public
        let backwards:Bool?
        public
        let caseFirst:CaseFirst?
        public
        let caseLevel:Bool?
        /// Determines up to which characters are considered ignorable when
        /// ``alternate`` is ``Alternate/shifted``. Has no effect when using
        /// ``Alternate/nonignorable``.
        ///
        /// This is modeled as a separate property from ``alternate`` because
        /// it depends the value of ``alternate``, rather than its presence.
        public
        let maxVariable:MaxVariable?
        public
        let normalization:Bool?
        public
        let numericOrdering:Bool?
        public
        let strength:Strength?

        @inlinable public
        init(locale:String,
            alternate:Alternate? = nil,
            backwards:Bool? = nil,
            caseFirst:CaseFirst? = nil,
            caseLevel:Bool? = nil,
            maxVariable:MaxVariable? = nil,
            normalization:Bool? = nil,
            numericOrdering:Bool? = nil,
            strength:Strength? = nil)
        {
            self.locale = locale
            self.alternate = alternate
            self.backwards = backwards
            self.caseFirst = caseFirst
            self.caseLevel = caseLevel
            self.maxVariable = maxVariable
            self.normalization = normalization
            self.numericOrdering = numericOrdering
            self.strength = strength
        }
    }
}
extension Mongo.Collation
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case locale
        case strength
        case caseLevel
        case caseFirst
        case numericOrdering
        case normalization
        case backwards
        case alternate
        case maxVariable
    }
}
extension Mongo.Collation:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(locale: try bson[.locale].decode(to: String.self),
            alternate: try bson[.alternate]?.decode(to: Alternate.self),
            backwards: try bson[.backwards]?.decode(to: Bool.self),
            caseFirst: try bson[.caseFirst]?.decode(to: CaseFirst.self),
            caseLevel: try bson[.caseLevel]?.decode(to: Bool.self),
            maxVariable: try bson[.maxVariable]?.decode(to: MaxVariable.self),
            normalization: try bson[.normalization]?.decode(to: Bool.self),
            numericOrdering: try bson[.numericOrdering]?.decode(to: Bool.self),
            strength: try bson[.strength]?.decode(to: Strength.self))
    }
}
extension Mongo.Collation:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.locale] = self.locale
        bson[.strength] = self.strength
        bson[.caseLevel] = self.caseLevel
        bson[.caseFirst] = self.caseFirst
        bson[.numericOrdering] = self.numericOrdering
        bson[.normalization] = self.normalization
        bson[.backwards] = self.backwards
        bson[.alternate] = self.alternate
        bson[.maxVariable] = self.maxVariable
    }
}
