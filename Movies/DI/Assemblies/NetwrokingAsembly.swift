
import Swinject
import TheMovieDB

struct NetwrokingAsembly: Assembly {
    func assemble(container: Container) {
        container.register(TokenResolverProtocol.self) { _ in TokenResovler() }
        container
            .register(NetworkPathObserverProtocol.self) { _ in NetworkPathObserver() }
            .inObjectScope(.container)
        container
            .register(AuthorizationPlugin.self) {
                let tokenResolver = $0.resolve(TokenResolverProtocol.self)!
                return AuthorizationPlugin {
                    tokenResolver.resolveToken()
                }
            }
        container.register(CachePlugin.self) { _ in
            CachePlugin.setCacheSize()
            return CachePlugin()
        }
        container
            .register(TheMovieDBAPIProvider.self) {
                MoyaProvider<TheMovieDBAPI>(plugins: [
                    $0.resolve(AuthorizationPlugin.self)!,
                    $0.resolve(CachePlugin.self)!,
                ])
            }
            .inObjectScope(.container)
    }
}
