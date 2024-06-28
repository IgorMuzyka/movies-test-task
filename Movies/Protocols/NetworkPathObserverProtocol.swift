
import Combine

protocol NetworkPathObserverProtocol {
    var isNetworkAvailable: CurrentValueSubject<Bool, Never> { get }
    func start()
    func stop()
}
