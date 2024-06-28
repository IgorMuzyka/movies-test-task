
import UIKit

final class MovieDetailsCoordinator: MovieDetailsCoordinatorProtocol {
    let router: RouterProtocol
    
    init(router: RouterProtocol) {
        self.router = router
    }

    func presentErrorAlert(from source: UIViewController, animated: Bool, error: any Swift.Error) {
        let controller = router.errorAlert(for: error)
        source.present(controller, animated: animated)
    }

    func presentTrailer(from source: UIViewController, animated: Bool, trailerURL: URL) {
        let controller = router.trailer(for: trailerURL)
        controller.modalPresentationStyle = .formSheet
        source.present(controller, animated: animated)
    }

    func presentPoster(from source: UIViewController, animated: Bool, poster: UIImage) {
        let controller = router.poster(for: poster)
        controller.modalPresentationStyle = .overFullScreen
        source.present(controller, animated: animated)
    }
}
