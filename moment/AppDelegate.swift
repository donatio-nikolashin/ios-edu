import UIKit
import Firebase
import RealmSwift
import FirebaseFirestore
import FirebaseStorage
import DITranquillity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var appViewController = UINavigationController(rootViewController: DIContainer.shared.resolve() as LoginViewController)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupDI()
        setupWindow()
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .init(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }

    func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appViewController
        window?.makeKeyAndVisible()
    }

    private func setupDI() {
        let container = DIContainer.shared
        container.register { Firestore.firestore() }.lifetime(.single)
        container.register { Storage.storage() }.lifetime(.single)
        container.register { RealmPhotoCache() }.lifetime(.single)
        container.register { RealmImageCache() }.lifetime(.single)
        container.register { PhotoFirestoreImpl(firestore: $0, storage: $1) }.as(PhotoFirestore.self)
        container.register { PhotoProviderImpl(cache: $0, firestore: $1) }.as(PhotoProvider.self)
        container.register { ImageProviderImpl(cache: $0, storage: $1) }.as(ImageProvider.self)
        container.register { AddPostViewController() }.lifetime(.single)
        container.register { CommentViewController(photoFirestore: $0) }.lifetime(.single)
        container.register {
            LoginViewController(
                    feedTableViewController: $0,
                    registrationViewController: $1
            )
        }.lifetime(.single)
        container.register {
            FeedTableViewController(
                    photoFirestore: $0,
                    photoProvider: $1,
                    addPostViewController: $2,
                    commentViewController: $3,
                    loginViewController: $4
            )
        }.lifetime(.single)
        container.register {
            RegistrationViewController(
                    firestore: $0,
                    feedTableViewController: $1
            )
        }.lifetime(.single)
        assert(container.makeGraph().checkIsValid())
    }

}

extension DIContainer {

    public static let shared = DIContainer()

}

