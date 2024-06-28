
import UIKit
import WebKit

final class MovieDetailsVideoPreviewViewController: UIViewController {
    private let videoURL: URL
    private let webView = WKWebView()
    // MARK: - init
    init(videoURL: URL) {
        self.videoURL = videoURL
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
        webView.glue(to: view)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: videoURL))
    }
}
