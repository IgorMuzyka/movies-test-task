
public enum TheMovieDBAPI {
    case discoverMovies(sortDescriptor: Movie.SortDescriptor, page: Int)
    case genres
    case movieVideos(movieID: Movie.ID)
    case movieDetails(movieID: Movie.ID)
    case searchMovie(query: String, page: Int)
    case poster(path: String, size: Movie.PosterSize)
}

import Moya
import Foundation

// MARK: Moya.TargetType
extension TheMovieDBAPI: TargetType {
    public var baseURL: URL {
        switch self {
            case .discoverMovies, .genres,  .movieVideos, .searchMovie, .movieDetails:
                URL(string: "https://api.themoviedb.org/3/")!
            case .poster:
                URL(string: "https://image.tmdb.org/t/p/")!
        }
    }

    public var path: String {
        switch self {
            case .discoverMovies: "discover/movie"
            case .genres: "genre/movie/list"
            case .movieVideos(let movieID): "movie/\(movieID)/videos"
            case .searchMovie: "search/movie"
            case .poster(let path, let size): size.rawValue + path
            case .movieDetails(let movieID): "movie/\(movieID)"
        }
    }

    public var method: Moya.Method  {
        switch self {
            case .discoverMovies, .genres, .movieVideos, .searchMovie, .poster, .movieDetails: .get
        }
    }

    public var task: Moya.Task {
        switch self {
            case .genres, .movieVideos, .poster, .movieDetails: .requestPlain
            case .discoverMovies(let sortDescriptor, let page): .requestParameters(
                parameters: [
                    "sort_by": sortDescriptor.rawValue,
                    "include_adult": true,
                    "page": "\(page)"
                ],
                encoding: URLEncoding.queryString
            )
            case .searchMovie(let query, let page): .requestParameters(
                parameters: [
                    "include_adult": true,
                    "query": query,
                    "page": "\(page)",
                ],
                encoding: URLEncoding.queryString
            )
        }
    }

    public var headers: [String : String]? {
        switch self {
            case .discoverMovies, .genres,  .movieVideos, .searchMovie, .movieDetails: ["Content-type": "application/json"]
            case .poster: .none
        }
    }
}
// MARK: AuthorizedTargetType
extension TheMovieDBAPI: AuthorizedTargetType {
    var needsAuth: Bool {
        switch self {
            case .discoverMovies, .genres, .movieVideos, .searchMovie, .movieDetails: true
            case .poster: false
        }
    }
}
// MARK: CacheableTargetType
extension TheMovieDBAPI: CacheableTargetType {
    var cachePolity: URLRequest.CachePolicy {
        switch self {
            case .genres, .movieVideos, .poster, .discoverMovies, .movieDetails: .returnCacheDataElseLoad
            case .searchMovie: .reloadIgnoringLocalCacheData
        }
    }
}
// MARK: CodableResponseTargetType
extension TheMovieDBAPI: CodableResponseTargetType {
    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(dateDecoder)
        return decoder
    }()
    private static func dateDecoder(_ decoder: any Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = yearMonthDayDateFormatter.date(from: dateString) else {
            return .distantFuture
        }
        return date
    }
    private static let yearMonthDayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
