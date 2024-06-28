
import Combine
import TheMovieDB

final class MoviesFeedService: MoviesFeedServiceProtocol {
    private let apiProvider: TheMovieDBAPIProvider

    init(apiProvider: TheMovieDBAPIProvider) {
        self.apiProvider = apiProvider
    }

    func genres() -> AnyPublisher<[Genre], MoyaError> {
        apiProvider.genresPublisher().map { $0.genres }.eraseToAnyPublisher()
    }

    func movies(sortDescriptor: Movie.SortDescriptor, page: Int) -> AnyPublisher<[Movie], MoyaError> {
        apiProvider.discoverMoviesPublisher(sortDescriptor: sortDescriptor, page: page)
            .map { $0.results }
            .eraseToAnyPublisher()
    }

    func search(query: String, page: Int) -> AnyPublisher<[Movie], MoyaError> {
        apiProvider.searchMoviePublisher(query: query, page: page).map { $0.results }.eraseToAnyPublisher()
    }

    func poster(path: String, size: Movie.PosterSize) -> AnyPublisher<Image, MoyaError> {
        apiProvider.posterPublisher(path: path, size: size)
    }
}
