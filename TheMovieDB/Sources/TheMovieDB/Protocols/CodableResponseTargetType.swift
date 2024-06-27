
import CombineMoya
import Foundation

public protocol CodableResponseTargetType: TargetType {
    static var decoder: JSONDecoder { get }
}

import Combine

public extension MoyaProvider where Target: CodableResponseTargetType {
    func codableRequestPublisher<CodableResponse: Codable>(
        _ target: Target,
        callbackQueue: DispatchQueue? = .none
    ) -> AnyPublisher<CodableResponse, MoyaError> {
        requestPublisher(target, callbackQueue: callbackQueue)
            .map(CodableResponse.self, using: Target.decoder)
    }
}
