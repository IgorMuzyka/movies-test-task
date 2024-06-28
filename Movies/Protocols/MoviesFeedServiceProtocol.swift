
import Combine
import TheMovieDB

protocol MoviesFeedServiceProtocol {
    func genres() -> AnyPublisher<[Genre], MoyaError>
    func movies(sortDescriptor: Movie.SortDescriptor, page: Int) -> AnyPublisher<[Movie], MoyaError>
    func search(query: String, page: Int) -> AnyPublisher<[Movie], MoyaError>
    func poster(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError>
}
