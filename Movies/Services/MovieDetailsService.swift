
import Combine
import TheMovieDB

final class MovieDetailsService: MovieDetailsServiceProtocol {
    private let apiProvider: TheMovieDBAPIProvider

    init(apiProvider: TheMovieDBAPIProvider) {
        self.apiProvider = apiProvider
    }

    func movieDetails(for movieID: Movie.ID) -> AnyPublisher<Movie.Details, MoyaError> {
        apiProvider.movieDetailsPublisher(for: movieID)
    }
    func poster(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError> {
        apiProvider.posterPublisher(path: path, size: size)
    }
    func videos(for movieID: Movie.ID) -> AnyPublisher<[Video], MoyaError> {
        apiProvider.movieVideosPublisher(for: movieID).map { $0.results }.eraseToAnyPublisher()
    }
}
