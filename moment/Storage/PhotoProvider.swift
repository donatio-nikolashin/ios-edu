import UIKit

protocol PhotoProvider {

    func fetch(force: Bool, completion: @escaping ([Photo]?, Error?) -> ())

}

class PhotoProviderImpl: PhotoProvider {

    private let cache: RealmPhotoCache
    private let firestore: PhotoFirestore

    init(cache: RealmPhotoCache, firestore: PhotoFirestore) {
        self.cache = cache
        self.firestore = firestore
    }

    func fetch(force: Bool = false, completion: @escaping ([Photo]?, Error?) -> ()) {
        Task {
            if force {
                await firestore.fetch { photos, error in
                    guard error == nil, let photos = photos else {
                        completion(nil, error)
                        return
                    }
                    completion(photos, nil)
                    DispatchQueue.global(qos: .background).async {
                        self.cache.save(photos) { error in
                            if let error = error {
                                print("Unexpected error: \(error).")
                            }
                        }
                    }
                }
            } else {
                cache.fetch { cached, error in
                    guard error == nil, let cached = cached else {
                        completion(nil, error)
                        return
                    }
                    if cached.isEmpty {
                        Task {
                            await self.firestore.fetch { photos, error in
                                guard error == nil, let photos = photos else {
                                    completion(nil, error)
                                    return
                                }
                                completion(photos, nil)
                                DispatchQueue.global(qos: .background).async {
                                    self.cache.save(photos) { error in
                                        if let error = error {
                                            print("Unexpected error: \(error).")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        completion(cached, nil)
                    }
                }
            }
        }
    }

}