
import UIKit
import TheMovieDB

protocol RouterProtocol {
    func root() -> UIViewController
    func moviesFeed() -> UIViewController
    func movieFeedSortDescriptorOptions(
        selected: Movie.SortDescriptor,
        didSelect: @escaping (Movie.SortDescriptor) -> Void
    ) -> UIViewController
    func movieDetails(for movie: Movie) -> UIViewController
    func errorAlert(for error: any Swift.Error) -> UIViewController
    func trailer(for trailerURL: URL) -> UIViewController
    func poster(for image: UIImage) -> UIViewController
}
