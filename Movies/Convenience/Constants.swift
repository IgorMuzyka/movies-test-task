
import UIKit

enum Constants {
    enum Animation {
        static let duration: TimeInterval = 0.65
    }

    enum MoviesFeed {
        enum Cell {
            static let aspectRatio: CGFloat = 3/4
            static let padding: CGFloat = 16
            static let genresWidthRatio: CGFloat = 8/10
            static let shadowOffset: CGSize = .init(width: 0, height: 2)
            static let textShadowOffset: CGSize = .zero
            static let shadowRadius: CGFloat = 2
        }
        enum Search {
            static let debounce: DispatchQueue.SchedulerTimeType.Stride = .microseconds(200)
            static let throttle: DispatchQueue.SchedulerTimeType.Stride = .microseconds(400)
        }
        static let noSearchResultsHeight: CGFloat = 64
        /// how much of existing `contentSize.height` needs to be scrolled to start fetching next page
        static let nextPageFetchingThreshold: CGFloat = 3/4
    }

    enum MovieDetails {
        static let posterAspectRatio: CGFloat = 3/4
        static let padding: CGFloat = 16
        static let trailerButtonHeight: CGFloat = 48

        enum PosterPreview {
            static let maxScale: CGFloat = 2.0
        }
    }

    enum ActivityIndicator {
        static let height: CGFloat = 2
        static let padding: CGFloat = 8
        static let cornerRadius: CGFloat = 1.75
    }

    enum Font {
        static let title: UIFont = .systemFont(ofSize: 19, weight: .bold)
        static let subTitle: UIFont = .systemFont(ofSize: 16, weight: .semibold)
        static let standard: UIFont = .systemFont(ofSize: 14)
        static let semibold: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    }
}
