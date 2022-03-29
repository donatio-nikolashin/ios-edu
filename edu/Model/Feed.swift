class UnsplashImage: Codable {
    public let urls: UnsplashImageUrls
    public let user: UnsplashUser
    public let width: Double
    public let height: Double
    public let description: String?
    public var likes: Int
    public var liked_by_user: Bool
}

class UnsplashImageUrls: Codable {
    public let regular: String
}

class UnsplashUser: Codable {
    public let username: String
    public let profile_image: UnsplashUserProfileImage
}

class UnsplashUserProfileImage: Codable {
    public let large: String
}
