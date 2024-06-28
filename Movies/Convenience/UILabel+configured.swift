
import UIKit

extension UILabel {
    static func configured(
        frame: CGRect,
        textAlignment: NSTextAlignment = .left,
        font: UIFont = Constants.Font.standard,
        multiline: Bool = false
    ) -> UILabel {
        let label = UILabel(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = textAlignment
        if multiline {
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.contentMode = .topLeft
        } else {
            label.numberOfLines = 1
        }
        label.baselineAdjustment = .alignBaselines
        label.font = font
        return label
    }
}
