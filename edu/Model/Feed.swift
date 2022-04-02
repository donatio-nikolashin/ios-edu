struct UnsplashImage: Codable {
    public let urls: UnsplashImageUrls
    public let user: UnsplashUser
    public let width: Double
    public let height: Double
    public let description: String?
    public var likes: Int
    public var liked_by_user: Bool
}

struct UnsplashImageUrls: Codable {
    public let regular: String
}

struct UnsplashUser: Codable {
    public let username: String
    public let profile_image: UnsplashUserProfileImage
}

struct UnsplashUserProfileImage: Codable {
    public let large: String
}
