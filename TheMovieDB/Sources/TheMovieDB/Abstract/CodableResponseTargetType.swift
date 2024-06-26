
import Moya
import Foundation

public protocol CodableResponseTargetType {
    static var decoder: JSONDecoder { get }
}

import CombineMoya
import Combine

public extension MoyaProvider where Target: CodableResponseTargetType {
    func codableRequestPublisher<CodableResponse: Codable>(
        _ target: Target,
        callbackQueue: DispatchQueue? = .none
    ) -> AnyPublisher<CodableResponse, MoyaError> {
        return requestPublisher(target, callbackQueue: callbackQueue)
            .map(CodableResponse.self, using: Target.decoder)
    }
}
