
import UIKit
import TheMovieDB
import Peep

extension UIAlertController {
    static func movieFeedSortOptionsActionSheet(
        selected: Movie.SortDescriptor,
        didSelect: @escaping (Movie.SortDescriptor) -> Void
    ) -> UIAlertController {
        let controller = UIAlertController(
            title: String(localizable: .moviesFeedSortOptionsSheetTitle),
            message: .none,
            preferredStyle: .actionSheet
        )
        let options = Movie.SortDescriptor.movieSortDescriptorOptions
        let texts = options.keys.sorted()
        for text in texts {
            guard let descriptor = options[text] else { continue }
            let action = UIAlertAction(title: text, style: .default) { [weak controller] _ in
                Peep.play(sound: HapticFeedback.selection)
                didSelect(descriptor)
                controller?.dismiss(animated: true)
            }
            if descriptor == selected {
                action.setValue(UIImage(systemSymbol: .checkmark), forKey: "image")
            }
            controller.addAction(action)
        }
        controller.addAction(.init(title: String(localizable: .moviesFeedSortOptionsSheetCancelTitle), style: .cancel))
        return controller
    }
}

fileprivate extension Movie.SortDescriptor {
    static var movieSortDescriptorOptions: [String: Movie.SortDescriptor] {[
        String(localizable: .moviesFeedSortOptionPopularityDescending):
                .init(parameter: .popularity, ordering: .descending),
        String(localizable: .moviesFeedSortOptionPopularityAscending):
                .init(parameter: .popularity, ordering: .ascending),
        String(localizable: .moviesFeedSortOptionRatingDescending):
                .init(parameter: .voteAverage, ordering: .descending),
        String(localizable: .moviesFeedSortOptionRatingAscending):
                .init(parameter: .voteAverage, ordering: .ascending),
        String(localizable: .moviesFeedSortOptionTitleDescending):
                .init(parameter: .originalTitle, ordering: .descending),
        String(localizable: .moviesFeedSortOptionTitleAscending):
                .init(parameter: .originalTitle, ordering: .ascending),
        String(localizable: .moviesFeedSortOptionReleaseDateDescending):
                .init(parameter: .primaryReleaseDate, ordering: .descending),
        String(localizable: .moviesFeedSortOptionReleaseDateAscending):
                .init(parameter: .primaryReleaseDate, ordering: .ascending),
    ]}
}
