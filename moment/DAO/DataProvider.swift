import FirebaseFirestore
import FirebaseAuth

public protocol DataProvider {

    func fetchPhotos() async -> [Photo]

    func remove(_ like: Like)

    func like(_ photo: Photo) -> Like?

}

public class DataProviderImpl: DataProvider {

    private let db: Firestore

    public init(db: Firestore) {
        self.db = db
    }

    public func fetchPhotos() async -> [Photo] {
        var photos: [Photo] = []
        do {
            let documents: [QueryDocumentSnapshot] = (try await db.collection(_: "photos").getDocuments()).documents
            for document in documents {
                guard let width = document.data()["width"] as? Double else {
                    continue
                }
                guard let height = document.data()["height"] as? Double else {
                    continue
                }
                guard let userReference = document.data()["user"] as? DocumentReference,
                      let user = await fetchUserBy(reference: userReference)
                else {
                    continue
                }
                let comments = await fetchCommentsBy(reference: document.reference)
                let likes = await fetchLikesBy(reference: document.reference)
                photos.append(Photo(id: document.documentID,
                        width: width,
                        height: height,
                        user: user,
                        comments: comments,
                        descr: document.data()["descr"] as? String,
                        likes: likes,
                        likedByUser: likes.contains(where: { like in like.userRef == FirebaseAuth.Auth.auth().currentUser?.uid })
                ))
            }
        } catch {
            print("Unexpected error: \(error).")
        }
        return photos
    }

    private func fetchCommentsBy(reference: DocumentReference) async -> [Comment] {
        var result: [Comment] = []
        do {
            let comments: [QueryDocumentSnapshot] = (try await db.collection(_: "comments")
                    .whereField("photo", isEqualTo: reference).getDocuments()).documents
            for comment in comments {
                guard let text = comment.data()["comment"] as? String else {
                    continue
                }
                guard let userReference = comment.data()["user"] as? DocumentReference,
                      let user = await fetchUserBy(reference: userReference)
                else {
                    continue
                }
                result.append(Comment(comment: text, user: user))
            }
            return result
        } catch {
            print("Unexpected error: \(error).")
            return result
        }
    }

    private func fetchLikesBy(reference: DocumentReference) async -> [Like] {
        var result: [Like] = []
        do {
            let likes: [QueryDocumentSnapshot] = (try await db.collection(_: "likes")
                    .whereField("photo", isEqualTo: reference).getDocuments()).documents
            for like in likes {
                guard let photoReference = like.data()["photo"] as? DocumentReference
                else {
                    print("Unable to get like.photo")
                    continue
                }
                guard let userReference = like.data()["user"] as? DocumentReference
                else {
                    print("Unable to get like.user")
                    continue
                }
                result.append(Like(id: like.documentID, userRef: userReference.documentID, photoRef: photoReference.documentID))
            }
            return result
        } catch {
            print("Unexpected error: \(error).")
            return result
        }
    }

    public func remove(_ like: Like) {
        db.collection("likes").document(like.id).delete()
    }

    public func like(_ photo: Photo) -> Like? {
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            return nil
        }
        let likeRef = db.collection("likes").addDocument(data: [
            "photo": db.collection("photos").document(photo.id),
            "user": db.collection("users").document(currentUserUid)
        ])
        return Like(id: likeRef.documentID, userRef: currentUserUid, photoRef: photo.id)
    }

    private func fetchUserBy(reference: DocumentReference) async -> User? {
        do {
            let userDocument = try await db.collection(_: "users").document(reference.documentID).getDocument()
            guard let username = userDocument.data()?["username"] as? String else {
                return nil
            }
            return User(username: username)
        } catch {
            print("Unexpected error: \(error).")
            return nil
        }
    }

}
