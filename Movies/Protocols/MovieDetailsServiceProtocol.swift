
import Combine
import TheMovieDB

protocol MovieDetailsServiceProtocol {
    func movieDetails(for movieID: Movie.ID) -> AnyPublisher<Movie.Details, MoyaError>
    func poster(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError>
    func videos(for movieID: Movie.ID) -> AnyPublisher<[Video], MoyaError>
}
