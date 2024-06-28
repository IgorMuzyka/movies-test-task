
import UIKit

extension UIView {
    func glue(to parent: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: insets.left),
            topAnchor.constraint(equalTo: parent.topAnchor, constant: insets.top),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -insets.bottom),
        ])
    }
}
