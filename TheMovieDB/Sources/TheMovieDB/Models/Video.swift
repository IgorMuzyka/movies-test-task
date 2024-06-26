
public struct MovieVideosResponse: Codable {
    public let id: Movie.ID
    public let results: [Video]
}

public struct Video: Codable {
    public typealias ID = String
    public let id: ID
    public let name: String
    public let site: String
    public struct `Type`: RawRepresentable, ExpressibleByStringLiteral, Codable, Hashable, Equatable {
        public var rawValue: String

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        public init(stringLiteral value: StringLiteralType) {
            self.rawValue = value
        }
    }
    public let type: `Type`
    public let official: Bool
    public let size: Int
}

public extension Video.`Type` {
    static var trailer: Self = "Trailer"
    static var teaser: Self = "Teaser"
    static var featurette: Self = "Featurette"
    static var clip: Self = "Clip"
    static var behindTheScenes: Self = "Behind the Scenes"
    static var bloopers: Self = "Bloopers"
}
