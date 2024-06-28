
import Swinject

struct RouterAssembly: Assembly {
    func assemble(container: Container) {
        container.register(RouterProtocol.self) {
            Router(resolver: $0)
        }
    }
}
