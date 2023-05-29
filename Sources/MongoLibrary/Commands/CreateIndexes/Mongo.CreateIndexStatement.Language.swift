extension Mongo.CreateIndexStatement
{
    @frozen public
    enum Language:String, Hashable, Sendable
    {
        case languageDefault = "default_language"
        case languageOverride = "language_override"
    }
}
extension Mongo.CreateIndexStatement.Language
{
    @available(*, unavailable, renamed: "languageDefault")
    public static
    var default_language:Self { .languageDefault }

    @available(*, unavailable, renamed: "languageOverride")
    public static
    var language_override:Self { .languageOverride }
}
