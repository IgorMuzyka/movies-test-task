
import Foundation.NSURLRequest
import Moya

public struct AuthorizationPlugin: PluginType {
    public let fetchToken: () -> String?
    public init(_ tokenProvider: @escaping () -> String?) {
        fetchToken = tokenProvider
    }
    public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        guard
            let authorizedTarget = target as? AuthorizedTargetType,
            authorizedTarget.needsAuth,
            let token = fetchToken()
        else {
            return request
        }
        var request = request
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}
