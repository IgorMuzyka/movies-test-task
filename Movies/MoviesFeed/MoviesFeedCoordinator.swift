
import UIKit
import TheMovieDB
import Peep

final class MoviesFeedCoordinator: MoviesFeedCoordinatorProtocol {
    let router: RouterProtocol

    init(router: RouterProtocol) {
        self.router = router
    }

    func presentSortOptionsActionSheet(
        from source: UIViewController,
        animated: Bool,
        selected: Movie.SortDescriptor,
        didSelect: @escaping (Movie.SortDescriptor) -> Void
    ) {
        let controller = router.movieFeedSortDescriptorOptions(selected: selected, didSelect: didSelect)
        source.present(controller, animated: animated)
    }

    func presentErrorAlert(from source: UIViewController, animated: Bool, error: any Swift.Error) {
        let controller = router.errorAlert(for: error)
        source.present(controller, animated: animated)
    }

    func presentMovieDetails(from source: UIViewController, animated: Bool, movie: Movie) {
        let controller = router.movieDetails(for: movie)
        source.navigationController?.pushViewController(controller, animated: animated)
    }
}
