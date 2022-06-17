import UIKit
import FirebaseStorage

protocol ImageProvider {

    func fetch(_ id: String, completion: @escaping (Data?, Error?) -> ())

}

class ImageProviderImpl: ImageProvider {

    private let storage: Storage
    private let cache: RealmImageCache

    init(cache: RealmImageCache, storage: Storage) {
        self.cache = cache
        self.storage = storage
    }

    func fetch(_ id: String, completion: @escaping (Data?, Error?) -> ()) {
        cache.fetch(id: id) { cached, error in
            if error != nil || cached == nil {
                self.storage.reference(withPath: self.photoRefFor(id)).getData(maxSize: 1 * 1024 * 1024) { data, error in
                    guard error == nil, let data = data else {
                        completion(nil, error)
                        return
                    }
                    completion(data, nil)
                    DispatchQueue.global(qos: .background).async {
                        self.cache.save(RealmData(id: id, data: data)) { error in
                            if let error = error {
                                print("Unexpected error: \(error).")
                            }
                        }
                    }
                }
            } else {
                completion(cached, nil)
            }
        }
    }

    private func photoRefFor(_ id: String) -> String {
        "photos/" + id + ".jpeg"
    }

}