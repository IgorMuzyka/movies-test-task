
import Moya

protocol AuthorizedTargetType: TargetType {
    var needsAuth: Bool { get }
}
