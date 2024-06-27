
import CombineMoya
import Combine

public extension MoyaProvider where Target == TheMovieDBAPI {
    func discoverMoviesPublisher(
        sortDescriptor: Movie.SortDescriptor = .standard,
        page: Int
    ) -> AnyPublisher<MoviesResponse, MoyaError> {
        codableRequestPublisher(.discoverMovies(sortDescriptor: sortDescriptor, page: page))
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
    func poster(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError> {
        requestPublisher(.poster(path: path, size: size), callbackQueue: .none)
            .mapImage()
    }
}
