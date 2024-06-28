
import Network
import Combine

final class NetworkPathObserver: NetworkPathObserverProtocol {
    private let monitor = NWPathMonitor()
    public let isNetworkAvailable: CurrentValueSubject<Bool, Never> = .init(false)

    public init() {
        monitor.pathUpdateHandler = { [weak self] in
            self?.isNetworkAvailable.send($0.status != .unsatisfied)
        }
    }

    deinit {
        monitor.cancel()
    }

    public func start() {
        let queue = DispatchQueue(label: String(reflecting: type(of: self)))
        monitor.start(queue: queue)
    }

    public func stop() {
        monitor.cancel()
    }
}
