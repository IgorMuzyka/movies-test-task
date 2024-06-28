
import UIKit
import Swinject
import TheMovieDB

struct MoviesFeedAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MoviesFeedServiceProtocol.self) {
            MoviesFeedService(apiProvider: $0.resolve(TheMovieDBAPIProvider.self)!)
        }
        container.register(MoviesFeedCoordinatorProtocol.self) {
            MoviesFeedCoordinator(router: $0.resolve(RouterProtocol.self)!)
        }
        container.register(MoviesFeedViewProtocol.self) {
            MoviesFeedViewController(viewModel: $0.resolve(MoviesFeedViewModelProtocol.self)!)
        }
        container.register(MoviesFeedViewModelProtocol.self) {
            MoviesFeedViewModel(
                coordinator: $0.resolve(MoviesFeedCoordinatorProtocol.self)!,
                networkPathObserver: $0.resolve(NetworkPathObserverProtocol.self)!,
                moviesFeedService: $0.resolve(MoviesFeedServiceProtocol.self)!
            )
        }
        container.register(UIAlertController.self) { (resolver: any Resolver, error: any Swift.Error) in
            let controller = UIAlertController(
                title: String(localizable: .errorAlertTitle),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            controller.addAction(.init(title: String(localizable: .errorAlertOkButtonTitle), style: .default))
            return controller
        }
        container.register(UIAlertController.self) { 
            (
                resolver: any Resolver,
                selected: Movie.SortDescriptor,
                didSelect: @escaping (Movie.SortDescriptor) -> Void
            ) in
                .movieFeedSortOptionsActionSheet(selected: selected, didSelect: didSelect)
        }
    }
}
