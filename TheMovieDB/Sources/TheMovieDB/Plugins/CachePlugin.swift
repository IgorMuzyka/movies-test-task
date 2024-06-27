

import Foundation.NSURLRequest
import Moya

public struct CachePlugin: PluginType {
    public init() {}
    public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
        guard let cacheableTarget = target as? CacheableTargetType else { return request }
        var request = request
        request.cachePolicy = cacheableTarget.cachePolity
        return request
    }
}

public extension CachePlugin {
    /// set cache size for memory and disk in mega bytes
    static func setCacheSize(memory: UInt = 64, disk: UInt = 512) {
        let multiplier = 1024 * 1024
        URLCache.shared = URLCache(
            memoryCapacity: Int(memory) * multiplier,
            diskCapacity: Int(disk) * multiplier
        )
    }
}
