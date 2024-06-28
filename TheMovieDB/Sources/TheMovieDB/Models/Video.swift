
public struct MovieVideosResponse: Codable {
    public let id: Movie.ID
    public let results: [Video]
}

public struct Video: Codable {
    public typealias ID = String
    public let id: ID
    public let name: String
    public let key: String
    public struct Site: RawRepresentable, ExpressibleByStringLiteral, Codable, Hashable, Equatable, CustomStringConvertible {
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

        public var description: String { rawValue }
    }
    public let site: Site
    public struct `Type`: RawRepresentable, ExpressibleByStringLiteral, Codable, Hashable, Equatable, CustomStringConvertible {
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

        public var description: String { rawValue }
    }
    public let type: `Type`
    public let official: Bool
    public let size: Int
}

public extension Video.`Type` {
    static let trailer: Self = "Trailer"
    static let teaser: Self = "Teaser"
    static let featurette: Self = "Featurette"
    static let clip: Self = "Clip"
    static let behindTheScenes: Self = "Behind the Scenes"
    static let bloopers: Self = "Bloopers"
}

public extension Video.Site {
    static let youtube: Self = "YouTube"
    static let vimeo: Self = "Vimeo"
}

import Foundation.NSURL

public extension Video {
    var trailerURL: URL? {
        guard official, type == .trailer else { return .none }
        switch site {
            case .youtube: return URL(string: "https://www.youtube.com/watch?v=\(key)")
            case .vimeo: return URL(string: "https://vimeo.com/\(key)")
            default: return .none
        }
    }
}
