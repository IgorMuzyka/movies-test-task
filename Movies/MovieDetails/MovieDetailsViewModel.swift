
import Foundation
import Combine
import TheMovieDB
import Peep

final class MovieDetailsViewModel: MovieDetailsViewModelProtocol {
    // MARK: - Dependencies
    private let movieDetailsService: MovieDetailsServiceProtocol
    private let coordinator: MovieDetailsCoordinatorProtocol
    private let networkPathObserver: NetworkPathObserverProtocol
    // MARK: - MovieDetailsViewModelProtocol
    private unowned var view: MovieDetailsViewProtocol!
    public let movie: Movie
    public var isNetworkAvailable: Bool { networkPathObserver.isNetworkAvailable.value }
    // MARK: - Internals
    private var cancellable = Set<AnyCancellable>()
    private var viewObservations = Set<AnyCancellable>()
    private var activityStack: Set<UUID> = [] {
        didSet {
            isNetworkUtilized.send(!activityStack.isEmpty)
        }
    }
    private let details: CurrentValueSubject<Movie.Details?, Never> = .init(.none)
    private let poster: CurrentValueSubject<Image?, Never> = .init(.none)
    private let videos: CurrentValueSubject<[Video]?, Never> = .init(.none)
    private let networkError = PassthroughSubject<any Swift.Error, Never>()
    private let isNetworkUtilized: CurrentValueSubject<Bool, Never> = .init(false)
    public var hasTrailer: Bool {
        guard case .some = trailer else { return false }
        return true
    }
    private var trailer: Video? {
        guard
            let videos = videos.value,
            let trailer = videos.first(where: { $0.trailerURL != .none })
        else { return .none }
        return trailer
    }
    private var hasPoster: Bool {
        guard let _ = movie.posterPath else { return false }
        return true
    }
    // MARK: - init
    init(
        movie: Movie,
        coordinator: MovieDetailsCoordinatorProtocol,
        networkPathObserver: NetworkPathObserverProtocol,
        movieDetailsService: MovieDetailsServiceProtocol
        
    ) {
        self.movie = movie
        self.coordinator = coordinator
        self.networkPathObserver = networkPathObserver
        self.movieDetailsService = movieDetailsService
    }
}
// MARK: - View Observations
fileprivate extension MovieDetailsViewModel {
    func observeNetworkStatus() {
        networkPathObserver.isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] in
                view?.updateNetworkStatus($0)
            }
            .store(in: &viewObservations)
    }

    func observeNetworkActivity() {
        isNetworkUtilized
            .receive(on: DispatchQueue.main)
            .sink { [unowned view] (isShown: Bool) in
                view?.toggleActivityIndicator(isShown)
            }
            .store(in: &viewObservations)
    }

    func observeNetworkErrorEvent() {
        networkError
            .receive(on: DispatchQueue.main)
            .sink { [unowned coordinator, weak view] in
                guard let view else { return }
                coordinator.presentErrorAlert(from: view, animated: true, error: $0)
            }
            .store(in: &viewObservations)
    }

    func observePoster() {
        poster
            .receive(on: DispatchQueue.main)
            .sink { [weak view] in
                view?.setPoster($0)
            }
            .store(in: &viewObservations)
    }

    func observeDetails() {
        details
            .receive(on: DispatchQueue.main)
            .sink { [weak view] in
                view?.setDetails($0)
            }
            .store(in: &viewObservations)
    }

    func observeVideos() {
        videos
            .receive(on: DispatchQueue.main)
            .sink { [weak view] in
                view?.setVideos($0)
            }
            .store(in: &viewObservations)
    }
}
// MARK: - MovieDetailsViewModelProtocol (state manipulation)
extension MovieDetailsViewModel {
    func assign(_ view: any MovieDetailsViewProtocol) {
        self.view = view
    }

    func fetch() {
        fetchDetails()
        fetchPosterIfPresent()
        fetchVideos()
    }

    func presentPoster() {
        guard let poster = poster.value else { return }
        Peep.play(sound: HapticFeedback.selection)
        coordinator.presentPoster(from: view, animated: true, poster: poster)
    }

    func presentTrailer() {
        guard isNetworkAvailable, let trailerURL = trailer?.trailerURL else { return }
        Peep.play(sound: HapticFeedback.selection)
        coordinator.presentTrailer(from: view, animated: true, trailerURL: trailerURL)
    }

    func setupObservers() {
        observeNetworkStatus()
        observeNetworkActivity()
        observeNetworkErrorEvent()
        observePoster()
        observeDetails()
        observeVideos()
    }

    func dismantleObservers() {
        viewObservations = []
    }
}
// MARK: - Fetching
fileprivate extension MovieDetailsViewModel {
    func fetchDetails() {
        let id = UUID()
        activityStack.insert(id)
        movieDetailsService
            .movieDetails(for: movie.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.details.send($0) }
            .store(in: &cancellable)
    }

    func fetchPosterIfPresent() {
        guard let posterPath = movie.posterPath else { return }
        let id = UUID()
        activityStack.insert(id)
        movieDetailsService
            .poster(path: posterPath, size: .original)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.poster.send($0) }
            .store(in: &cancellable)

    }

    func fetchVideos() {
        let id = UUID()
        activityStack.insert(id)
        movieDetailsService
            .videos(for: movie.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.activityStack.remove(id)
                guard case .failure(let error) = result else { return }
                self?.networkError.send(error)
            } receiveValue: { [weak self] in self?.videos.send($0) }
            .store(in: &cancellable)
    }
}
