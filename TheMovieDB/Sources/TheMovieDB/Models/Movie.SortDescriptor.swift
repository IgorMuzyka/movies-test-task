
public extension Movie {
    struct SortDescriptor: Equatable, Hashable {
        public enum Parameter: String {
            case originalTitle = "original_title"
            case popularity = "popularity"
            case revenue = "revenue"
            case primaryReleaseDate = "primary_release_date"
            case title = "title"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
        public let parameter: Parameter

        public enum Ordering: String {
            case ascending = "asc"
            case descending = "desc"
        }
        public let ordering: Ordering

        public init(parameter: Parameter, ordering: Ordering) {
            self.parameter = parameter
            self.ordering = ordering
        }

        public var rawValue: String { parameter.rawValue + "." + ordering.rawValue }

        public static var standard: Self { .init(parameter: .popularity, ordering: .descending) }
    }
}
