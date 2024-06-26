
import Foundation

extension TheMovieDBAPI: CodableResponseTargetType {
    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom(dateDecoder)
        return decoder
    }()
    private static func dateDecoder(_ decoder: any Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = yearMonthDayDateFormatter.date(from: dateString) else {
            #if DEBUG
            print("failed to decode date for string:", dateString)
            #endif
            return .distantFuture
        }
        return date
    }
    private static let yearMonthDayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
}
