public class Photo: CustomStringConvertible {

    public let id: String
    public let width: Double
    public let height: Double
    public let user: User
    public var comments: [Comment]
    public let descr: String?
    public var likes: [Like]
    public var likedByUser: Bool

    public init(id: String, width: Double, height: Double, user: User, comments: [Comment], descr: String?, likes: [Like], likedByUser: Bool) {
        self.id = id
        self.width = width
        self.height = height
        self.user = user
        self.comments = comments
        self.descr = descr
        self.likes = likes
        self.likedByUser = likedByUser
    }

    public var description: String {
        "Photo(id: \(id), width: \(width), height: \(height), user: \(user), comments: \(comments), likes: \(likes), likedByUser: \(likedByUser))"
    }

}

public class Comment: CustomStringConvertible {

    public let comment: String
    public let user: User

    public init(comment: String, user: User) {
        self.comment = comment
        self.user = user
    }

    public var description: String {
        "Comment(comment: \(comment), User: \(user))"
    }

}

public class User: CustomStringConvertible {

    public static let ME = User(username: "You")
    public let username: String

    public init(username: String) {
        self.username = username
    }

    public var description: String {
        "User(username: \(username))"
    }

}

public class Like: CustomStringConvertible {

    public let id: String
    public let userRef: String
    public let photoRef: String

    public init(id: String, userRef: String, photoRef: String) {
        self.id = id
        self.userRef = userRef
        self.photoRef = photoRef
    }

    public var description: String {
        "Like(id: \(id), userRef: \(userRef), photoRef: \(photoRef))"
    }

}