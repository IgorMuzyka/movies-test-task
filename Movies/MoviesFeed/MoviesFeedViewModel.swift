
import UIKit
import Combine
import TheMovieDB
import ScrollViewObserver
import Peep

final class MoviesFeedViewModel: NSObject, MoviesFeedViewModelProtocol {
    // MARK: - Dependencies
    private let networkPathObserver: NetworkPathObserverProtocol
    private let moviesFeedService: MoviesFeedServiceProtocol
    private let coordinator: MoviesFeedCoordinatorProtocol
    // MARK: - MoviesFeedViewModelProtocol
    private unowned var view: MoviesFeedViewProtocol!
    public var isNetworkAvailable: Bool { networkPathObserver.isNetworkAvailable.value }
    // MARK: - Internals
    private var cancellable = Set<AnyCancellable>()
    private var viewObservations = Set<AnyCancellable>()
    private var dataSource: MoviesFeedDataSource!
    private var pagingScrollViewOffsetMonitor: ScrollViewOffsetMonitor!
    private var sortDescriptor: Movie.SortDescriptor = .standard
    private let searchQuery: CurrentValueSubject<String, Never> = .init(String())
    // MARK: - init
    init(
        coordinator: MoviesFeedCoordinatorProtocol,
        networkPathObserver: NetworkPathObserverProtocol,
        moviesFeedService: MoviesFeedServiceProtocol
    ) {
        self.coordinator = coordinator
        self.networkPathObserver = networkPathObserver
        self.moviesFeedService = moviesFeedService
        super.init()
    }

    deinit {
        networkPathObserver.stop()
        pagingScrollViewOffsetMonitor?.stop()
    }
}
// MARK: - View Observations
fileprivate extension MoviesFeedViewModel {
    func observeNetworkStatus() {
        networkPathObserver.isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak view, weak self] in
                if $0 {
                    self?.refresh()
                }
                view?.updateNetworkStatus($0)
            }
            .store(in: &viewObservations)
    }

    func observeNetworkActivity() {
        dataSource.isNetworkUtilized
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] in
                view?.toggleActivityIndicator($0)
            }
            .store(in: &viewObservations)
    }

    func observeNetworkErrorEvent() {
        dataSource.networkError
            .receive(on: DispatchQueue.main)
            .sink { [unowned coordinator, unowned view] in
                coordinator.presentErrorAlert(from: view!, animated: true, error: $0)
            }
            .store(in: &viewObservations)
    }

    func observeSearchQuery() {
        searchQuery
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] in
                view?.toggleSortOptions($0.isEmpty)
            }
            .store(in: &viewObservations)
    }

    func observeNoSearchResultsEvent() {
        dataSource.shouldPresentNoResults
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] in
                view?.toggleNoSearchResults($0)
            }
            .store(in: &viewObservations)
    }

    func observeEmptyState() {
        dataSource.shouldPresentEmptyState
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] in
                view?.toggleNoCache($0)
            }
            .store(in: &viewObservations)
    }

    enum Error: Swift.Error, LocalizedError {
        case movieDetailsUnavailableWhileOffline
        var errorDescription: String? {
            switch self {
                case .movieDetailsUnavailableWhileOffline: 
                    String(localizable: .errorMovieDetailsUnavailableWhileOffline)
            }
        }
    }

    func observeMovieSelectionEvent() {
        dataSource.didSelectMovie
            .receive(on: DispatchQueue.main)
            .sink { [unowned self, unowned coordinator, unowned view] (movie: Movie) in
                if isNetworkAvailable {
                    coordinator.presentMovieDetails(from: view!, animated: true, movie: movie)
                } else {
                    dataSource.switchTo(mode: .movies(sortDescriptor: sortDescriptor))
                    coordinator.presentErrorAlert(
                        from: view!,
                        animated: true,
                        error: Error.movieDetailsUnavailableWhileOffline
                    )
                }
            }
            .store(in: &viewObservations)
    }
}

// MARK: - Setup
fileprivate extension MoviesFeedViewModel {
    func setupDataSource(with collectionView: UICollectionView) {
        dataSource = MoviesFeedDataSource(
            mode: .movies(sortDescriptor: sortDescriptor),
            service: moviesFeedService,
            collectionView: collectionView
        )
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
    }

    func observeScrollViewOffset(in scrollView: UIScrollView) {
        pagingScrollViewOffsetMonitor = ScrollViewOffsetMonitor(
            scrollView: scrollView,
            tresholdProvider: { scrollView in
                scrollView.contentSize.height * Constants.MoviesFeed.nextPageFetchingThreshold
            },
            callback: { [weak self] isOverTreshold in
                guard let self, isOverTreshold, isNetworkAvailable else { return }
                dataSource.fetchNextPage()
            }
        )
        pagingScrollViewOffsetMonitor.start()
    }

    func observeSearchQueryInput() {
        searchQuery
            .receive(on: DispatchQueue.main)
            .dropFirst(2)
            .debounce(for: Constants.MoviesFeed.Search.debounce, scheduler: DispatchQueue.main)
            .throttle(for: Constants.MoviesFeed.Search.throttle, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] searchQuery in
                guard let self, isNetworkAvailable else { return }
                if searchQuery.isEmpty {
                    dataSource.switchTo(mode: .movies(sortDescriptor: sortDescriptor))
                } else {
                    dataSource.switchTo(mode: .search(query: searchQuery))
                }
                fetch()
            }
            .store(in: &cancellable)
    }
}

// MARK: - MoviesFeedViewModelProtocol (state manipulation)
extension MoviesFeedViewModel {
    func setup(with collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        observeScrollViewOffset(in: collectionView)
        observeSearchQueryInput()
        observeNetworkStatus()
        networkPathObserver.start()
    }

    func apply(_ sortDescriptor: Movie.SortDescriptor) {
        guard sortDescriptor != self.sortDescriptor else { return }
        self.sortDescriptor = sortDescriptor
        dataSource.switchTo(mode: .movies(sortDescriptor: sortDescriptor))
        dataSource.fetch()
    }

    func refresh() {
        dataSource.reset()
        dataSource.fetch()
    }

    func fetch() {
        dataSource.fetch()
    }

    func setupObservers() {
        observeNetworkActivity()
        observeNetworkErrorEvent()
        observeSearchQuery()
        observeNoSearchResultsEvent()
        observeEmptyState()
        observeMovieSelectionEvent()
    }

    func dismantleObservers() {
        viewObservations = []
    }

    func assign(_ view: MoviesFeedViewProtocol) {
        self.view = view
    }

    func presentSortActionSheet() {
        Peep.play(sound: HapticFeedback.selection)
        coordinator.presentSortOptionsActionSheet(
            from: view,
            animated: true,
            selected: sortDescriptor
        ) { [weak self] in
            self?.apply($0)
        }
    }
}

// MARK: - MoviesFeedViewModelProtocol (UISearchBarDelegate)
extension MoviesFeedViewModel: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            Peep.play(sound: HapticFeedback.selection)
        }
        searchQuery.send(searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Peep.play(sound: HapticFeedback.selection)
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: .none, from: .none, for: .none)
    }
}
