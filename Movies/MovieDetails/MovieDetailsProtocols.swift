
import UIKit
import Combine
import TheMovieDB

protocol MovieDetailsViewModelProtocol: AnyObject {
    var isNetworkAvailable: Bool { get }
    var movie: Movie { get }
    var hasTrailer: Bool { get }
    func assign(_ view: MovieDetailsViewProtocol)
    func fetch()
    func setupObservers()
    func dismantleObservers()
    func presentTrailer()
    func presentPoster()
}

protocol MovieDetailsViewProtocol: UIViewController {
    func setPoster(_ image: UIImage?)
    func setDetails(_ details: Movie.Details?)
    func setVideos(_ videos: [Video]?)
    func toggleActivityIndicator(_ isShown: Bool)
    func updateNetworkStatus(_ isNetworkAvailable: Bool)
}

protocol MovieDetailsCoordinatorProtocol: AnyObject {
    func presentErrorAlert(from source: UIViewController, animated: Bool, error: any Swift.Error)
    func presentTrailer(from source: UIViewController, animated: Bool, trailerURL: URL)
    func presentPoster(from source: UIViewController, animated: Bool, poster: UIImage)
}
