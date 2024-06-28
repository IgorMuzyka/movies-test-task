
import UIKit
import TheMovieDB
import SFSafeSymbols
import GradientLoadingBar

final class MovieDetailsViewController: UIViewController, MovieDetailsViewProtocol {
    private let viewModel: MovieDetailsViewModelProtocol
    private let activityIndicator = GradientActivityIndicatorView()
    private let poster = UIImageView()
    private var releaseDateAndCountry: UILabel!
    private var genres: UILabel!
    private var rating: UILabel!
    private var trailer = UIButton()
    private var overview: UILabel!

    // MARK: - init
    init(viewModel: MovieDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: .none, bundle: .none)
        viewModel.assign(self)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.setupObservers()
        viewModel.fetch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.dismantleObservers()
    }
    // MARK: - Setup
    private func setup() {
        setupView()
        navigationItem.title = viewModel.movie.originalTitle
        rating.text = String(localizable: .movieDetailsRatingTitle(viewModel.movie.rating))
        overview.text = viewModel.movie.overview
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        poster.clipsToBounds = true
        poster.contentMode = .scaleAspectFit
        poster.translatesAutoresizingMaskIntoConstraints = false
        poster.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewPosterInFullscreen))
        tapGesture.numberOfTapsRequired = 1
        poster.addGestureRecognizer(tapGesture)
        view.addSubview(poster)
        releaseDateAndCountry = .configured(frame: view.frame, multiline: true)
        view.addSubview(releaseDateAndCountry)
        genres = .configured(frame: view.frame, multiline: true)
        view.addSubview(genres)
        rating = .configured(frame: view.frame, textAlignment: .right, font: Constants.Font.semibold)
        view.addSubview(rating)
        trailer.translatesAutoresizingMaskIntoConstraints = false
        trailer.setBackgroundImage(UIImage(systemSymbol: .videoCircleFill), for: .normal)
        trailer.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
        view.addSubview(trailer)
        trailer.isEnabled = viewModel.isNetworkAvailable && viewModel.hasTrailer
        overview = .configured(frame: view.frame, textAlignment: .left, multiline: true)
        view.addSubview(overview)
        setupActivityIndicator()
        let padding: CGFloat = Constants.MovieDetails.padding
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            poster.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            poster.heightAnchor.constraint(equalTo: poster.widthAnchor, multiplier: Constants.MovieDetails.posterAspectRatio),

            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.ActivityIndicator.padding),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.ActivityIndicator.padding),
            activityIndicator.heightAnchor.constraint(equalToConstant: Constants.ActivityIndicator.height),

            releaseDateAndCountry.topAnchor.constraint(equalTo: poster.bottomAnchor, constant: padding),
            releaseDateAndCountry.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            releaseDateAndCountry.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

            genres.topAnchor.constraint(equalTo: releaseDateAndCountry.bottomAnchor, constant: padding),
            genres.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            genres.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),

            trailer.topAnchor.constraint(equalTo: genres.bottomAnchor, constant: padding),
            trailer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            trailer.heightAnchor.constraint(equalToConstant: Constants.MovieDetails.trailerButtonHeight),
            trailer.widthAnchor.constraint(equalTo: trailer.heightAnchor),

            rating.leadingAnchor.constraint(equalTo: trailer.trailingAnchor, constant: padding),
            rating.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            rating.centerYAnchor.constraint(equalTo: trailer.centerYAnchor),
            rating.heightAnchor.constraint(equalTo: trailer.heightAnchor),

            overview.topAnchor.constraint(equalTo: trailer.bottomAnchor, constant: padding),
            overview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            overview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.fadeOut(duration: 0)
        view.addSubview(activityIndicator)
        activityIndicator.layer.cornerRadius = Constants.ActivityIndicator.cornerRadius
    }
    // MARK: - Actions
    @objc private func playTrailer(_ button: UIButton) {
        viewModel.presentTrailer()
    }
    @objc private func previewPosterInFullscreen(_ gesture: UIGestureRecognizer) {
        viewModel.presentPoster()
    }
}
// MARK: - MovieDetailsViewProtocol
extension MovieDetailsViewController {
    func setPoster(_ image: UIImage?) {
        poster.image = image
    }

    func setDetails(_ details: Movie.Details?) {
        guard let details else { return }
        genres.text = details.genres.map(\.name).joined(separator: ", ")
        releaseDateAndCountry.text = describeReleaseDateAndCountry(movie: viewModel.movie, details: details)
    }

    func setVideos(_ videos: [Video]?) {
        trailer.isEnabled = viewModel.isNetworkAvailable
        trailer.isHidden = !viewModel.hasTrailer
    }

    func toggleActivityIndicator(_ isShown: Bool) {
        if isShown {
            activityIndicator.fadeIn()
        } else {
            activityIndicator.fadeOut()
        }
    }

    func updateNetworkStatus(_ isNetworkAvailable: Bool) {
        trailer.isEnabled = isNetworkAvailable 
        trailer.isHidden = !viewModel.hasTrailer
    }
}
// MARK: - Convenience
fileprivate extension MovieDetailsViewController {
    func describeReleaseDateAndCountry(movie: Movie, details: Movie.Details) -> String {
        let releaseYear = movie.releaseYear
        let countries = details.productionCountries
            .compactMap { country in
                guard let flag = country.flag else { return .none }
                return flag + " " + country.name
            }
            .joined(separator: ", ")
        return !countries.isEmpty
            ? countries + ", " + releaseYear
            : releaseYear
    }
}
