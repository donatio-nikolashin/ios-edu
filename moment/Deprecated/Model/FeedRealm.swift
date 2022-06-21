import UIKit
import RealmSwift

class RealmPhoto: Object {

    @Persisted public var id: String = ""
    @Persisted public var width: Double = 0
    @Persisted public var height: Double = 0
    @Persisted public var user: RealmUser?
    @Persisted public var comments: List<RealmComment> = List()
    @Persisted public var descr: String?
    @Persisted public var likes: List<RealmLike> = List()
    @Persisted public var likedByUser: Bool = false

    func asModel() -> Photo {
        Photo(id: id,
                width: width,
                height: height,
                user: (user ?? RealmUser()).asModel(),
                comments: comments.toArray().map { comment in
                    comment.asModel()
                },
                descr: descr,
                likes: likes.toArray().map { like in
                    like.asModel()
                },
                likedByUser: likedByUser)
    }

}

class RealmComment: Object {

    @Persisted public var comment: String = ""
    @Persisted public var user: RealmUser?
    @Persisted public var commentByUser: Bool = false

    func asModel() -> Comment {
        Comment(comment: comment, user: (user ?? RealmUser()).asModel(), commentByUser: commentByUser)
    }

}

class RealmUser: Object {

    @Persisted public var username: String = ""

    func asModel() -> User {
        User(username: username)
    }

}

class RealmLike: Object {

    @Persisted public var id: String = ""
    @Persisted public var userRef: String = ""
    @Persisted public var photoRef: String = ""

    func asModel() -> Like {
        Like(id: id, userRef: userRef, photoRef: photoRef)
    }

}

class RealmData: Object {

    override init() {
        super.init()
    }

    init(id: String, data: Data) {
        self.id = id
        self.data = data
    }

    @Persisted public var id: String = ""
    @Persisted public var data: Data = Data()

}