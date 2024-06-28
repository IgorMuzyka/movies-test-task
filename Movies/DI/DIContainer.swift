
import Swinject

final class DIContainer {
    private let container = Container()
    private let assembler: Assembler

    static let shared = DIContainer()

    init() {
        self.assembler = Assembler(
            [
                NetwrokingAsembly(),
                RouterAssembly(),
                MoviesFeedAssembly(),
                MovieDetailsAssembly(),
            ],
            container: container
        )
    }

    func resolve<T>() -> T {
        guard let resolvedType = container.resolve(T.self) else {
            fatalError()
        }
        return resolvedType
    }
}
