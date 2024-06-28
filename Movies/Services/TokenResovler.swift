
import Foundation.NSBundle

struct TokenResovler: TokenResolverProtocol {
    private let key: String = "TheMovieDBAPIToken"

    func resolveToken() -> String {
        guard let apiToken = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("Specify value for \"\(key)\" in Info.plist")
        }
        return apiToken
    }
}
