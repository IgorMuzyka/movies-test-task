
import CombineMoya
import Combine

extension MoyaProvider: TheMovieDBAPIProvider where Target == TheMovieDBAPI {
    public func discoverMoviesPublisher(
        sortDescriptor: Movie.SortDescriptor = .standard,
        page: Int
    ) -> AnyPublisher<MoviesResponse, MoyaError> {
        codableRequestPublisher(.discoverMovies(sortDescriptor: sortDescriptor, page: page))
    }
    public func genresPublisher() -> AnyPublisher<GenresResponse, MoyaError> {
        codableRequestPublisher(.genres)
    }
    public func movieVideosPublisher(for movieID: Movie.ID) -> AnyPublisher<MovieVideosResponse, MoyaError> {
        codableRequestPublisher(.movieVideos(movieID: movieID))
    }
    public func searchMoviePublisher(query: String, page: Int) -> AnyPublisher<MoviesResponse, MoyaError> {
        codableRequestPublisher(.searchMovie(query: query, page: page))
    }
    public func posterPublisher(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError> {
        requestPublisher(.poster(path: path, size: size), callbackQueue: .none)
            .mapImage()
    }
    public func movieDetailsPublisher(for movieID: Movie.ID) -> AnyPublisher<Movie.Details, MoyaError> {
        codableRequestPublisher(.movieDetails(movieID: movieID))
    }
}
