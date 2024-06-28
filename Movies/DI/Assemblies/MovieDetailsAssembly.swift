
import Swinject
import TheMovieDB
import Foundation.NSURL
import UIKit.UIImage

struct MovieDetailsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MovieDetailsServiceProtocol.self) {
            MovieDetailsService(apiProvider: $0.resolve(TheMovieDBAPIProvider.self)!)
        }
        container.register(MovieDetailsCoordinatorProtocol.self) {
            MovieDetailsCoordinator(router: $0.resolve(RouterProtocol.self)!)
        }
        container.register(MovieDetailsViewModelProtocol.self) { (resolver: any Resolver, movie: Movie) in
            MovieDetailsViewModel(
                movie: movie,
                coordinator: resolver.resolve(MovieDetailsCoordinatorProtocol.self)!,
                networkPathObserver: resolver.resolve(NetworkPathObserverProtocol.self)!,
                movieDetailsService: resolver.resolve(MovieDetailsServiceProtocol.self)!
            )
        }
        container.register(MovieDetailsViewProtocol.self) { (resolver: any Resolver, movie: Movie) in
            MovieDetailsViewController(
                viewModel: resolver.resolve(MovieDetailsViewModelProtocol.self, argument: movie)!
            )
        }
        container.register(MovieDetailsVideoPreviewViewController.self) { (resolver: any Resolver, url: URL) in
            MovieDetailsVideoPreviewViewController(videoURL: url)
        }
        container.register(MovieDetailsPosterPreviewViewController.self) { (resolver: any Resolver, image: UIImage) in
            MovieDetailsPosterPreviewViewController(poster: image)
        }
    }
}
