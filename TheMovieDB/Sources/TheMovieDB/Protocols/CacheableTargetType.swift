
import Foundation.NSURLRequest
import Moya

protocol CacheableTargetType: TargetType {
    var cachePolity: URLRequest.CachePolicy { get }
}
