class UnsplashImage: Codable {

    public let id: String
    public let urls: UnsplashImageUrls
    public let user: UnsplashUser
    public let width: Double
    public let height: Double
    public let description: String?
    public var likes: Int
    public var likedByUser: Bool
    public var comments: [UnsplashImageComment]? = []

    enum CodingKeys: String, CodingKey {
        case id
        case urls
        case user
        case width
        case height
        case description
        case likes
        case likedByUser = "liked_by_user"
        case comments
    }

}

class UnsplashImageUrls: Codable {
    public let regular: String
}

class UnsplashUser: Codable {

    public static let ME = UnsplashUser(username: "You", profileImage: UnsplashUserProfileImage.NONE)

    public let username: String
    public let profileImage: UnsplashUserProfileImage

    init(username: String, profileImage: UnsplashUserProfileImage) {
        self.username = username
        self.profileImage = profileImage
    }

    enum CodingKeys: String, CodingKey {
        case username
        case profileImage = "profile_image"
    }

}

class UnsplashUserProfileImage: Codable {

    public static let NONE = UnsplashUserProfileImage(large: "https://images.unsplash.com/placeholder-avatars/extra-large.jpg?dpr=2&auto=format&fit=crop&w=50&h=50&q=60&crop=faces&bg=fff")

    public let large: String

    init(large: String) {
        self.large = large
    }

}

class UnsplashImageComment: Codable {

    public let comment: String
    public let user: UnsplashUser

    init(_ comment: String) {
        self.comment = comment
        user = UnsplashUser.ME
    }

    init(comment: String, user: UnsplashUser) {
        self.comment = comment
        self.user = user
    }

}
