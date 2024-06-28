
import UIKit
import SFSafeSymbols
import GradientLoadingBar
import TheMovieDB

final class MoviesFeedViewController: UIViewController, MoviesFeedViewProtocol {
    private let viewModel: MoviesFeedViewModelProtocol
    private var collectionView: UICollectionView!
    private var refreshControl = UIRefreshControl()
    private let searchBar = UISearchBar()
    private var noSearchResults: UILabel!
    private let activityIndicator = GradientActivityIndicatorView()
    // MARK: - init
    init(
        viewModel: MoviesFeedViewModelProtocol
    ) {
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
        viewModel.setup(with: collectionView)
        searchBar.delegate = viewModel
        navigationItem.title = String(localizable: .moviesFeedNavigationTitle)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemSymbol: .arrowUpArrowDownSquareFill).withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(presentSortActionSheet)
        )
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        refreshControl.attributedTitle = NSAttributedString(string: String(localizable: .moviesFeedRefreshControlTitle))
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        view.addSubview(collectionView)
    }

    private func setupSearchBar() {
        searchBar.placeholder = String(localizable: .moviesFeedSearchBarPlaceholder)
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .done
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.sizeToFit()
        view.addSubview(searchBar)
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.fadeOut(duration: 0)
        view.addSubview(activityIndicator)
        activityIndicator.layer.cornerRadius = Constants.ActivityIndicator.cornerRadius
    }

    private func setupNoSearchResultsLabel() {
        noSearchResults = UILabel(frame: view.frame)
        noSearchResults.translatesAutoresizingMaskIntoConstraints = false
        noSearchResults.textAlignment = .center
        noSearchResults.numberOfLines = 1
        noSearchResults.contentMode = .top
        noSearchResults.font = Constants.Font.standard
        noSearchResults.isHidden = true
        view.addSubview(noSearchResults)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupCollectionView()
        setupActivityIndicator()
        setupNoSearchResultsLabel()
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.ActivityIndicator.padding),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Animation.duration),
            activityIndicator.heightAnchor.constraint(equalToConstant: Constants.ActivityIndicator.height),

            noSearchResults.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            noSearchResults.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noSearchResults.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noSearchResults.heightAnchor.constraint(equalToConstant: Constants.MoviesFeed.noSearchResultsHeight),
        ])
    }
    // MARK: - Actions
    @objc private func pullToRefresh(_ sender: UIRefreshControl) {
        guard viewModel.isNetworkAvailable else {
            refreshControl.endRefreshing()
            return
        }
        viewModel.refresh()
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.duration) { [weak refreshControl] in
            refreshControl?.endRefreshing()
        }
    }
    @objc private func presentSortActionSheet(_ sender: UIBarButtonItem) {
        viewModel.presentSortActionSheet()
    }
}

// MARK: - MoviesFeedViewProtocol
extension MoviesFeedViewController {
    func toggleActivityIndicator(_ isShown: Bool) {
        if isShown {
            activityIndicator.fadeIn()
        } else {
            activityIndicator.fadeOut()
        }
    }

    func toggleNoSearchResults(_ shouldPresentNoResults: Bool) {
        UIView.animate(withDuration: Constants.Animation.duration) { [weak self] in
            if shouldPresentNoResults {
                self?.noSearchResults.text = String(localizable: .moviesFeedNoSearchResultsTitle)
            }
            self?.collectionView.isHidden = shouldPresentNoResults
            self?.noSearchResults.isHidden = !shouldPresentNoResults
        }
    }

    func toggleNoCache(_ shouldPresentNoCache: Bool) {
        UIView.animate(withDuration: Constants.Animation.duration) { [weak self] in
            if shouldPresentNoCache {
                self?.noSearchResults.text = String(localizable: .moviesFeedEmptyStateTitle)
            }
            self?.collectionView.isHidden = shouldPresentNoCache
            self?.noSearchResults.isHidden = !shouldPresentNoCache
        }
    }

    func toggleSortOptions(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }

    func updateNetworkStatus(_ isNetworkAvailable: Bool) {
        if !isNetworkAvailable {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemSymbol: .wifiSlash).withRenderingMode(.alwaysTemplate),
                style: .plain,
                target: .none,
                action: .none
            )
            navigationItem.leftBarButtonItem?.tintColor = .gray
        } else {
            navigationItem.leftBarButtonItem = .none
        }
        navigationItem.rightBarButtonItem?.isEnabled = isNetworkAvailable
        searchBar.isUserInteractionEnabled = isNetworkAvailable
    }
}
