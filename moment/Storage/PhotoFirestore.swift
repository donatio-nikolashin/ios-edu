import UIKit
import RealmSwift
import SwiftLazy
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol PhotoFirestore {

    func fetch(completion: @escaping ([Photo]?, Error?) -> Void) async

    func remove(_ like: Like)

    func like(_ photo: Photo) -> Like?

    func addComment(photo: Photo, comment: String, completion: @escaping (Comment) -> Void)

    func publish(image: UIImage, description: String?, completion: @escaping (_: StorageMetadata?, _: Error?) -> Void)

}


class PhotoFirestoreImpl: PhotoFirestore {

    private let firestore: Firestore
    private let storage: Storage

    init(firestore: Firestore, storage: Storage) {
        self.firestore = firestore
        self.storage = storage
    }

    func fetch(completion: @escaping ([Photo]?, Error?) -> Void) async {
        var result: [Photo] = []
        do {
            let photos: [QueryDocumentSnapshot] = (try await firestore.collection("photos").getDocuments()).documents
            for photo in photos {
                guard let width = photo.data()["width"] as? Double,
                      let height = photo.data()["height"] as? Double,
                      let userReference = photo.data()["user"] as? DocumentReference,
                      let user = await fetchUserBy(reference: userReference)
                else {
                    print("Photo skipped due to guard fail")
                    continue
                }
                let comments = await fetchCommentsBy(reference: photo.reference)
                let likes = await fetchLikesBy(reference: photo.reference)
                result.append(Photo(
                        id: photo.documentID,
                        width: width,
                        height: height,
                        user: user,
                        comments: comments,
                        descr: photo.data()["descr"] as? String,
                        likes: likes,
                        likedByUser: likes.contains(where: { like in like.userRef == FirebaseAuth.Auth.auth().currentUser?.uid })
                ))
            }
            completion(result, nil)
        } catch {
            completion(nil, error)
        }
    }

    private func fetchCommentsBy(reference: DocumentReference) async -> [Comment] {
        var result: [Comment] = []
        do {
            let comments: [QueryDocumentSnapshot] = (try await firestore.collection(_: "comments")
                    .whereField("photo", isEqualTo: reference).getDocuments()).documents
            for comment in comments {
                guard let text = comment.data()["comment"] as? String,
                      let userReference = comment.data()["user"] as? DocumentReference,
                      let user = await fetchUserBy(reference: userReference),
                      let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid
                else {
                    print("Comment skipped due to guard fail")
                    continue
                }
                result.append(Comment(comment: text, user: user, commentByUser: userReference.documentID == currentUserUid))
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
            let likes: [QueryDocumentSnapshot] = (try await firestore.collection(_: "likes")
                    .whereField("photo", isEqualTo: reference).getDocuments()).documents
            for like in likes {
                guard let photoReference = like.data()["photo"] as? DocumentReference,
                      let userReference = like.data()["user"] as? DocumentReference
                else {
                    print("Like skipped due to guard fail")
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

    func remove(_ like: Like) {
        firestore.collection("likes").document(like.id).delete()
    }

    func like(_ photo: Photo) -> Like? {
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            return nil
        }
        let likeRef = firestore.collection("likes").addDocument(data: [
            "photo": firestore.collection("photos").document(photo.id),
            "user": firestore.collection("users").document(currentUserUid)
        ])
        return Like(id: likeRef.documentID, userRef: currentUserUid, photoRef: photo.id)
    }

    // Test library provided deserialization
    private func fetchUserBy(reference: DocumentReference, completion: @escaping (User?, Error?) -> Void) {
        firestore.collection("users").document(reference.documentID).getDocument(as: User.self) { result in
            do {
                try completion(result.get(), nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    private func fetchUserBy(reference: DocumentReference) async -> User? {
        do {
            let userDocument = try await firestore.collection(_: "users").document(reference.documentID).getDocument()
            guard let username = userDocument.data()?["username"] as? String else {
                return nil
            }
            return User(username: username)
        } catch {
            print("Unexpected error: \(error).")
            return nil
        }
    }

    func publish(image: UIImage, description: String?, completion: @escaping (_: StorageMetadata?, _: Error?) -> Void) {
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            return
        }
        let documentRef = firestore.collection("photos").addDocument(data: [
            "width": image.size.width,
            "height": image.size.height,
            "descr": description as Any,
            "user": firestore.collection("users").document(currentUserUid)
        ])
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storage.reference(withPath: photoRefFor(documentRef.documentID))
                .putData(image.compress(to: 800, allowedMargin: 0.02), metadata: metadata, completion: completion)
    }

    func addComment(photo: Photo, comment: String, completion: @escaping (Comment) -> Void) {
        guard let currentUserUid = FirebaseAuth.Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = firestore.collection("users").document(currentUserUid)
        firestore.collection("comments").addDocument(data: [
            "comment": comment,
            "photo": firestore.collection("photos").document(photo.id),
            "user": userRef
        ])
        fetchUserBy(reference: userRef) { user, error in
            guard let user = user else {
                return
            }
            DispatchQueue.main.async {
                completion(Comment(comment: comment, user: user, commentByUser: true))
            }
        }
    }

    private func photoRefFor(_ id: String) -> String {
        "photos/" + id + ".jpeg"
    }

}
