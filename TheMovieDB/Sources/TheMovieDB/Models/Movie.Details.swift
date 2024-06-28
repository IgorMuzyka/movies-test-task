
import Foundation.NSDate
import IsoCountryCodes

public extension Movie {
    struct Details: Codable {
        public let budget: Int
        public let overview: String
        public let posterPath: String?
        public let genres: [Genre]
        public struct ProductionCountry: Codable {
            public let iso31661: String
            public let name: String
            public var flag: String? {
                IsoCountries.flag(countryCode: iso31661)
            }
        }
        public let productionCountries: [ProductionCountry]
        /// Format: `yyyy-MM-dd`, sometimes it's missing in that case it'll be `.distantFuture`.
        public let releaseDate: Date
        public let voteAverage: Double
    }
}
