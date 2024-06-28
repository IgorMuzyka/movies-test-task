
import UIKit
import TheMovieDB
import Swinject

/// more like a factory, but whatever
struct Router: RouterProtocol {
    let resolver: any Resolver

    init(resolver: any Resolver) {
        self.resolver = resolver
    }

    func root() -> UIViewController {
        UINavigationController(rootViewController: moviesFeed())
    }

    func moviesFeed() -> UIViewController {
        resolver.resolve(MoviesFeedViewProtocol.self)!
    }

    func movieFeedSortDescriptorOptions(
        selected: Movie.SortDescriptor,
        didSelect: @escaping (Movie.SortDescriptor) -> Void
    ) -> UIViewController {
        resolver.resolve(UIAlertController.self, arguments: selected, didSelect)!
    }

    func movieDetails(for movie: Movie) -> UIViewController {
        resolver.resolve(MovieDetailsViewProtocol.self, argument: movie)!
    }

    func errorAlert(for error: any Swift.Error) -> UIViewController {
        resolver.resolve(UIAlertController.self, argument: error)!
    }

    func trailer(for trailerURL: URL) -> UIViewController {
        resolver.resolve(MovieDetailsVideoPreviewViewController.self, argument: trailerURL)!
    }

    func poster(for image: UIImage) -> UIViewController {
        resolver.resolve(MovieDetailsPosterPreviewViewController.self, argument: image)!
    }
}
