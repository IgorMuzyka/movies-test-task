
public struct MoviesResponse: Codable {
    public let page: Int
    public let results: [Movie]
}

import Foundation.NSDate

public struct Movie: Codable {
    public typealias ID = UInt64
    public let id: ID
    public let title: String
    /// Format: `yyyy-MM-dd`, sometimes it's missing in that case it'll be `.distantFuture`.
    public let releaseDate: Date
    public let genreIds: [Genre.ID]
    public let overview: String
    public let posterPath: String?
    public let popularity: Double
    public let voteAverage: Double
    public let voteCount: Int
    public let adult: Bool
    public let backdropPath: String?
    /// it's some kind of `ISO`, maybe support it if you wanna
    public let originalLanguage: String
    public let originalTitle: String
    public let video: Bool
    /// passing `.none` or `nil` as width return `URL` for original size image
    public func posterURL(width: Int? = 500) -> URL? {
        guard let posterPath else { return .none }
        let url = TheMovieDBAPI.staticImagesBaseURL
        guard let width else {
            return url.appendingPathComponent("original").appendingPathComponent(posterPath)
        }
        return url.appendingPathComponent("w\(width)").appendingPathComponent(posterPath)
    }
}
