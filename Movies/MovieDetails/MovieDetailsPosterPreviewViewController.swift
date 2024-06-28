
import UIKit
import InteractiveImageView

final class MovieDetailsPosterPreviewViewController: UIViewController {
    private var imageView: InteractiveImageView!
    private let poster: UIImage
    // MARK: - init
    init(poster: UIImage) {
        self.poster = poster
        super.init(nibName: .none, bundle: .none)
    }

    @available(*, unavailable, message: "Use parametrized init")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    // MARK: - Setup
    private func setup() {
        view.backgroundColor = .clear
        imageView = InteractiveImageView(
            frame: view.frame,
            image: poster,
            maxScale: Constants.MovieDetails.PosterPreview.maxScale
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.glue(to: view)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoom))
        imageView.addGestureRecognizer(doubleTap)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipe.direction = .down
        swipe.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(swipe)
    }
    // MARK: - Actions
    @objc private func zoom(_ gesture: UITapGestureRecognizer) {
        imageView.zoom(
            to: gesture.location(in: imageView),
            scale: Constants.MovieDetails.PosterPreview.maxScale,
            animated: true
        )
    }
    @objc private func swipe(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
}
