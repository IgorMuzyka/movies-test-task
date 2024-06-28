
import XCTest
/*@testable */import TheMovieDB
import Combine
import Moya
import CombineMoya

final class TheMovieDBTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        CachePlugin.setCacheSize(memory: 0, disk: 0)
    }
    // MARK: - Tests
    func testDiscoverMoviesEndpoint() throws {
        let movies = try awaitPublisher(apiProvider.discoverMoviesPublisher(page: 1)).results
        XCTAssertEqual(movies.count, 20)
    }
    func testGenreListEndpoint() throws {
        let genres = try awaitPublisher(apiProvider.genresPublisher()).genres
        XCTAssert(!genres.isEmpty)
    }
    func testMovieVideosEndpoint() throws {
        let movies = try awaitPublisher(apiProvider.discoverMoviesPublisher(page: 1)).results
        var videos: [Video] = []
        for movie in movies {
            let movieVideos = try awaitPublisher(apiProvider.movieVideosPublisher(for: movie.id)).results
            videos.append(contentsOf: movieVideos)
        }
        XCTAssert(!videos.isEmpty)
    }
    func testSearchMovieEndpoint() throws {
        let searchResults = try awaitPublisher(apiProvider.searchMoviePublisher(query: "Star Wars", page: 1)).results
        XCTAssert(!searchResults.isEmpty)
    }
    func testPosterEndpoint() throws {
        let movies = try awaitPublisher(apiProvider.discoverMoviesPublisher(page: 1)).results
        guard let posterPath = movies.compactMap(\.posterPath).first else {
            XCTFail("none of popular movies had poster")
            return
        }
        do {
            let image = try awaitPublisher(apiProvider.posterPublisher(path: posterPath, size: .w500))
            XCTAssertEqual(image.size.width, 500)
        } catch {
            XCTFail("failed to load poster: " + error.localizedDescription)
        }
    }
    func testMovieDetailsEndpoint() throws {
        let movieID: Movie.ID = 573435
        let details = try awaitPublisher(apiProvider.movieDetailsPublisher(for: movieID))
        guard let productionCountry = details.productionCountries.first else {
            XCTFail("no production countries")
            return
        }
        guard let flag = productionCountry.flag else {
            XCTFail("no flag for production country")
            return
        }
        XCTAssertEqual(flag, "🇺🇸")
    }
//    func testDiscoverMovieVideoTypes() {
//        var page: Int = 1
//        let stop: Int = 20
//        var uniqueTypes: Set<Video.`Type`> = []
//        repeat {
//            let movies = try awaitPublisher(provider.popularMoviesPublisher(page: page)).results
//            for movie in movies {
//                let movieVideos = try awaitPublisher(provider.movieVides(for: movie.id)).results
//                for type in movieVideos.map(\.type) {
//                    uniqueTypes.insert(type)
//                }
//            }
//            page += 1
//            print(page)
//        } while page < stop
//        for type in uniqueTypes {
//            print(type.rawValue)
//        }
//    }
    // MARK: - Accessors
    private lazy var apiProvider: MoyaProvider<TheMovieDBAPI> = {
        .init(plugins: [
            AuthorizationPlugin { [unowned self] in token },
            CachePlugin(),
        ])
    }()
    /// yeah i know this is a malpractice, but this is a test task
    private var token: String {
        "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NjE0YjRmMDg3YjIyZTNkMTQ0MTIyOGNhNDg1MTI2ZCIsIm5iZiI6MTcxOTM5NzI4OC4xNzMyNzgsInN1YiI6IjY2N2JlYjJhODdiYmNlMzgyZGFhNmU4YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.BmPgf7-U0Olu1ZlaQ6Dn3U_cFpwAtKppWJggvxr4oxI"
    }
}
