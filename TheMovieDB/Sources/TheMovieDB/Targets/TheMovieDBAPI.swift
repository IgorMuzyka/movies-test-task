
public enum TheMovieDBAPI {
    case popularMovies(page: Int)
    case genres
    case movieVideos(movieID: Movie.ID)
    case searchMovie(query: String, page: Int)
}

import Moya
import Combine

public extension MoyaProvider where Target == TheMovieDBAPI {
    func popularMoviesPublisher(page: Int) -> AnyPublisher<MoviesResponse, MoyaError> {
        codableRequestPublisher(.popularMovies(page: page))
    }
    func genresPublisher() -> AnyPublisher<GenresResponse, MoyaError> {
        codableRequestPublisher(.genres)
    }
    func movieVides(for movieID: Movie.ID) -> AnyPublisher<MovieVideosResponse, MoyaError> {
        codableRequestPublisher(.movieVideos(movieID: movieID))
    }
    func searchMovie(query: String, page: Int) -> AnyPublisher<MoviesResponse, MoyaError> {
        codableRequestPublisher(.searchMovie(query: query, page: page))
    }
}

import Foundation.NSURL

extension TheMovieDBAPI: TargetType {
    public var baseURL: URL { URL(string: "https://api.themoviedb.org/3/")! }
    public static var staticImagesBaseURL: URL { URL(string: "https://image.tmdb.org/t/p/")! }

    public var path: String {
        switch self {
            case .popularMovies: "movie/popular"
            case .genres: "genre/movie/list"
            case .movieVideos(let movieID): "movie/\(movieID)/videos"
            case .searchMovie: "search/movie"
        }
    }

    public var method: Moya.Method  {
        switch self {
            case .popularMovies: .get
            case .genres: .get
            case .movieVideos: .get
            case .searchMovie: .get
        }
    }

    public var task: Moya.Task {
        switch self {
            case .popularMovies(let page): .requestParameters(
                parameters: [
                    "page": page
                ],
                encoding: URLEncoding.queryString
            )
            case .genres: .requestPlain
            case .movieVideos: .requestPlain
            case .searchMovie(let query, let page): .requestParameters(
                parameters: [
                    "page": page,
                    "includ_adult": true,
                    "query": query,
                ],
                encoding: URLEncoding.queryString
            )
        }
    }

    public var headers: [String : String]? {[
        "Content-type": "application/json",
    ]}
}

extension TheMovieDBAPI: AuthorizedTargetType {
    var needsAuth: Bool {
        switch self {
            case .popularMovies: true
            case .genres: true
            case .movieVideos: true
            case .searchMovie: true
        }
    }
}
