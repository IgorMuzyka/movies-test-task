
import UIKit
import Foundation
import Combine
import Micro
import TheMovieDB
import Peep

final class MoviesFeedDataSource: DataSource {
    private let service: MoviesFeedServiceProtocol
    private var activityStack: Set<UUID> = [] {
        didSet {
            isNetworkUtilized.send(!activityStack.isEmpty)
        }
    }
    private var page: Int = 1
    private var cancellable = Set<AnyCancellable>()
    private var movies = [Movie]() { didSet { refresh() } }
    private var searchResults = [Movie]() { didSet { refresh() } }
    private var genres: [Genre] = [] { didSet { refresh() } }
    enum Mode: Equatable {
        case search(query: String)
        case movies(sortDescriptor: Movie.SortDescriptor)
    }
    private var mode: Mode

    public let networkError = PassthroughSubject<any Swift.Error, Never>()
    public let isNetworkUtilized: CurrentValueSubject<Bool, Never> = .init(false)
    public let shouldPresentNoResults = PassthroughSubject<Bool, Never>()
    public let shouldPresentEmptyState = PassthroughSubject<Bool, Never>()
    public let didSelectMovie = PassthroughSubject<Movie, Never>()

    init(mode: Mode, service: MoviesFeedServiceProtocol, collectionView: UICollectionView) {
        self.mode = mode
        self.service = service
        super.init(collectionView: collectionView)
        fetchGenres()
    }

    // MARK: - State manipulation
    func switchTo(mode: Mode) {
        guard mode != self.mode else { return }
        reset()
        self.mode = mode
    }

    func reset() {
        page = 1
        cancellable = []
        activityStack = []
        switch mode {
            case .movies: 
                movies = []
            case .search: 
                searchResults = []
        }
    }

    func fetch() {
        switch mode {
            case .search(let query): fetchSearchResults(query)
            case .movies(let sortDescriptor): fetchMovies(sortDescriptor)
        }
    }

    func fetchNextPage() {
        page += 1
        fetch()
    }

    func refresh() { rebuildState() }
    // MARK: - Cell rendering
    private func rebuildState() {
        switch mode {
            case .search:
                state = State {
                    ForEach(searchResults, transform: renderMovieCell(_:))
                }
                shouldPresentNoResults.send(searchResults.isEmpty)
            case .movies:
                state = State {
                    ForEach(movies, transform: renderMovieCell(_:))
                }
                shouldPresentNoResults.send(false)
                shouldPresentEmptyState.send(movies.isEmpty)
        }
    }
    
    private func renderMovieCell(_ movie: Movie) -> ObserverOwner {
        Cell<MovieCell> { [unowned self] context, cell in
            cell.title.text = movie.title
            cell.releaseDate.text = movie.releaseYear
            cell.rating.text = movie.rating
            if let posterPath = movie.posterPath {
                cell.posterTask = fetchPoster(posterPath, for: cell)
            }
            cell.genres.text = describeGenres(for: movie)
        }
        .onSelect { [unowned self] context in
            guard let movie = self.movie(at: context.indexPath.item) else { return }
            Peep.play(sound: HapticFeedback.selection)
            didSelectMovie.send(movie)
        }
        .onSize { context in
            let containerSize = context.collectionView.frame.size
            return CGSize(
                width: containerSize.width - Constants.MoviesFeed.Cell.padding,
                height: containerSize.width * Constants.MoviesFeed.Cell.aspectRatio
            )
        }
    }
    // MARK: - Fetching
    private func fetchGenres() {
        let id = UUID()
        activityStack.insert(id)
        service
            .genres()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.genres = $0 }
            .store(in: &cancellable)
    }

    private func fetchMovies(_ sortDescriptor: Movie.SortDescriptor) {
        let id = UUID()
        activityStack.insert(id)
        service
            .movies(sortDescriptor: sortDescriptor, page: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.movies.append(contentsOf: $0) }
            .store(in: &cancellable)
    }

    private func fetchSearchResults(_ query: String) {
        let id = UUID()
        activityStack.insert(id)
        service.search(query: query, page: page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.searchResults.append(contentsOf: $0) }
            .store(in: &cancellable)
    }

    private func fetchPoster(_ posterPath: String, for cell: MovieCell) -> AnyCancellable {
        let id = UUID()
        activityStack.insert(id)
        return service
            .poster(path: posterPath, size: .w342)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak cell] in cell?.poster.image = $0 }
    }
    // MARK: - Convenience
    private func movie(at index: Int) -> Movie? {
        switch mode {
            case .search:
                guard searchResults.endIndex > index else { return .none }
                return searchResults[index]
            case .movies:
                guard movies.endIndex > index else { return .none }
                return movies[index]
        }
    }
    
    func describeGenres(for movie: Movie) -> String {
        genres
            .filter { movie.genreIds.contains($0.id) }
            .map(\.name)
            .joined(separator: ", ")
    }
}

// MARK: - DiffAware conformance
import DeepDiff
import UIKit

extension Movie: DiffAware {
    public var diffId: Movie.ID { id }
    public static func compareContent(_ a: Self, _ b: Self) -> Bool {
        a.originalTitle == b.originalTitle && a.releaseYear == b.releaseYear
    }
}
// MARK: - Convenience
extension Movie {
    var releaseYear: String {
        guard releaseDate != .distantFuture else { return String(localizable: .movieUnspecifiedReleaseDate) }
        let year = Calendar.current.component(.year, from: releaseDate)
        return "\(year)"
    }
    var rating: String {
        String(format: "%.1f", voteAverage)
    }
}
