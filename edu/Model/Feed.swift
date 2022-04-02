class UnsplashImage: Codable {

    public let id: String
    public let urls: UnsplashImageUrls
    public let user: UnsplashUser
    public let width: Double
    public let height: Double
    public let description: String?
    public var likes: Int
    public var likedByUser: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case urls
        case user
        case width
        case height
        case description
        case likes
        case likedByUser = "liked_by_user"
    }

}

class UnsplashImageUrls: Codable {
    public let regular: String
}

class UnsplashUser: Codable {

    public let username: String
    public let profileImage: UnsplashUserProfileImage

    enum CodingKeys: String, CodingKey {
        case username
        case profileImage = "profile_image"
    }

}

class UnsplashUserProfileImage: Codable {
    public let large: String
}
