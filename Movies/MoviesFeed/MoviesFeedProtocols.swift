
import UIKit
import TheMovieDB

protocol MoviesFeedViewModelProtocol: UISearchBarDelegate {
    var isNetworkAvailable: Bool { get }
    func assign(_ view: MoviesFeedViewProtocol)
    func setup(with collectionView: UICollectionView)
    func apply(_ sortDescriptor: Movie.SortDescriptor)
    func refresh()
    func fetch()
    func setupObservers()
    func dismantleObservers()
    func presentSortActionSheet()
}

protocol MoviesFeedViewProtocol: UIViewController {
    func toggleActivityIndicator(_ isShown: Bool)
    func toggleNoSearchResults(_ shouldPresentNoResults: Bool)
    func toggleNoCache(_ shouldPresentNoCache: Bool)
    func toggleSortOptions(_ isEnabled: Bool)
    func updateNetworkStatus(_ isNetworkAvailable: Bool)
}

protocol MoviesFeedCoordinatorProtocol: AnyObject {
    func presentErrorAlert(from source: UIViewController, animated: Bool, error: any Swift.Error)
    func presentSortOptionsActionSheet(
        from source: UIViewController,
        animated: Bool,
        selected: Movie.SortDescriptor,
        didSelect: @escaping (Movie.SortDescriptor) -> Void
    )
    func presentMovieDetails(from source: UIViewController, animated: Bool, movie: Movie)
}
