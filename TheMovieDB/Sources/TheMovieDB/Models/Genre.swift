
public struct GenresResponse: Codable {
    public let genres: [Genre]
}

public struct Genre: Codable {
    public typealias ID = Int
    public let id: ID
    public let name: String
}

