
import Combine

public protocol TheMovieDBAPIProvider {
    func discoverMoviesPublisher(
        sortDescriptor: Movie.SortDescriptor,
        page: Int
    ) -> AnyPublisher<MoviesResponse, MoyaError>
    func genresPublisher() -> AnyPublisher<GenresResponse, MoyaError>
    func movieVideosPublisher(for movieID: Movie.ID) -> AnyPublisher<MovieVideosResponse, MoyaError>
    func searchMoviePublisher(query: String, page: Int) -> AnyPublisher<MoviesResponse, MoyaError>
    func posterPublisher(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError>
    func movieDetailsPublisher(for movieID: Movie.ID) -> AnyPublisher<Movie.Details, MoyaError>
}
