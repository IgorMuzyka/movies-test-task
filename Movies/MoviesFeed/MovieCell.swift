
import UIKit
import QuartzCore
import Combine
import TheMovieDB

final class MovieCell: UICollectionViewCell {
    public var posterTask: AnyCancellable?
    public private(set) var title: UILabel!
    public private(set) var releaseDate: UILabel!
    public private(set) var genres: UILabel!
    public private(set) var rating: UILabel!
    public let poster = UIImageView()
    private var container: UIView!
    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable, message: "Use basic init")
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterTask?.cancel()
        posterTask = .none
        poster.image = .none
        title.text = .none
        releaseDate.text = .none
        genres.text = .none
        rating.text = .none
    }

    // MARK: - Setup
    private func setup() {
        container = UIView(frame: frame)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.glue(to: self)
        poster.clipsToBounds = true
        poster.contentMode = .scaleAspectFill
        poster.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(poster)
        title = .configured(frame: frame, font: Constants.Font.title, multiline: true)
        style(title)
        container.addSubview(title)
        releaseDate = .configured(frame: frame, font: Constants.Font.subTitle)
        style(releaseDate)
        container.addSubview(releaseDate)
        genres = .configured(frame: frame, multiline: true)
        style(genres)
        container.addSubview(genres)
        rating = .configured(frame: frame, textAlignment: .right)
        style(rating)
        container.addSubview(rating)
        let padding: CGFloat = Constants.MoviesFeed.Cell.padding
        NSLayoutConstraint.activate([
            poster.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            poster.topAnchor.constraint(equalTo: container.topAnchor),
            poster.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            poster.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            title.topAnchor.constraint(equalTo: container.topAnchor, constant: padding),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            releaseDate.topAnchor.constraint(equalTo: title.bottomAnchor, constant: padding),
            releaseDate.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            releaseDate.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            genres.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padding),
            genres.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padding),
            genres.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: Constants.MoviesFeed.Cell.genresWidthRatio),

            rating.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padding),
            rating.topAnchor.constraint(equalTo: genres.topAnchor),
        ])

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = Constants.MoviesFeed.Cell.shadowOffset
        layer.shadowOpacity = 1
        layer.shadowRadius = Constants.MoviesFeed.Cell.shadowRadius
    }

    func style(_ label: UILabel) {
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = Constants.MoviesFeed.Cell.textShadowOffset
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = Constants.MoviesFeed.Cell.shadowRadius
    }
}
