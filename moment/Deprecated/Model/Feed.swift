import RealmSwift

class Photo: CustomStringConvertible {

    let id: String
    let width: Double
    let height: Double
    let user: User
    var comments: [Comment]
    let descr: String?
    var likes: [Like]
    var likedByUser: Bool

    init(id: String, width: Double, height: Double, user: User, comments: [Comment], descr: String?, likes: [Like], likedByUser: Bool) {
        self.id = id
        self.width = width
        self.height = height
        self.user = user
        self.comments = comments
        self.descr = descr
        self.likes = likes
        self.likedByUser = likedByUser
    }

    var description: String {
        "Photo(id: \(id), width: \(width), height: \(height), user: \(user), comments: \(comments), likes: \(likes), likedByUser: \(likedByUser))"
    }

    func asRealmObject() -> RealmPhoto {
        let photo = RealmPhoto()
        photo.id = id
        photo.width = width
        photo.height = height
        photo.user = user.asRealmObject()
        photo.comments = comments.map { comment in
                    comment.asRealmObject()
                }
                .toList()
        photo.descr = descr
        photo.likes = likes.map { like in
                    like.asRealmObject()
                }
                .toList()
        photo.likedByUser = likedByUser
        return photo
    }

}

class Comment: CustomStringConvertible, Codable {

    let comment: String
    let user: User
    let commentByUser: Bool

    init(comment: String, user: User, commentByUser: Bool) {
        self.comment = comment
        self.user = user
        self.commentByUser = commentByUser
    }

    var description: String {
        "Comment(comment: \(comment), user: \(user), commentByUser: \(commentByUser))"
    }

    func asRealmObject() -> RealmComment {
        let rComment = RealmComment()
        rComment.comment = comment
        rComment.user = user.asRealmObject()
        rComment.commentByUser = commentByUser
        return rComment
    }

}

class User: CustomStringConvertible, Codable {

    var username: String

    init(username: String) {
        self.username = username
    }

    var description: String {
        "User(username: \(username))"
    }

    func asRealmObject() -> RealmUser {
        let user = RealmUser()
        user.username = username
        return user
    }

}

class Like: CustomStringConvertible {

    var id: String
    var userRef: String
    var photoRef: String

    init(id: String, userRef: String, photoRef: String) {
        self.id = id
        self.userRef = userRef
        self.photoRef = photoRef
    }

    var description: String {
        "Like(id: \(id), userRef: \(userRef), photoRef: \(photoRef))"
    }

    func asRealmObject() -> RealmLike {
        let like = RealmLike()
        like.id = id
        like.userRef = userRef
        like.photoRef = photoRef
        return like
    }

}