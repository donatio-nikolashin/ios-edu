import UIKit
import Realm
import RealmSwift

extension DispatchQueue {

    public static let realm = DispatchQueue(label: "realm")

}

class RealmPhotoCache {

    func fetch(completion: @escaping ([Photo]?, Error?) -> ()) {
        DispatchQueue.realm.sync {
            do {
                let realm = try Realm(queue: DispatchQueue.realm)
                completion(Array(realm.objects(RealmPhoto.self).map { photo in
                    photo.asModel()
                }), nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    func save(_ photos: [Photo], completion: @escaping (Error?) -> ()) {
        DispatchQueue.realm.sync {
            do {
                let realm = try Realm(queue: DispatchQueue.realm)
                try realm.write {
                    realm.delete(realm.objects(RealmPhoto.self))
                    realm.add(photos.map { photo in
                        photo.asRealmObject()
                    })
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

}

class RealmImageCache {

    func fetch(id: String, completion: @escaping (Data?, Error?) -> ()) {
        DispatchQueue.realm.sync {
            do {
                let realm = try Realm(queue: DispatchQueue.realm)
                guard let data = realm.objects(RealmData.self).where({ element in element.id == id }).first?.data else {
                    completion(nil, nil)
                    return
                }
                completion(data, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    func save(_ data: RealmData, completion: @escaping (Error?) -> ()) {
        DispatchQueue.realm.sync {
            do {
                let realm = try Realm(queue: DispatchQueue.realm)
                try realm.write {
                    realm.delete(realm.objects(RealmData.self).where({ element in element.id == data.id }))
                    realm.add(data)
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

}

