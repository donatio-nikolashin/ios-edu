import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import DITranquillity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var appViewController = UINavigationController(rootViewController: DIContainer.shared.resolve() as LoginViewController)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let container = DIContainer.shared
        container.register { LoginViewController() }
        container.register { RegistrationViewController() }
        container.register { FeedTableViewController() }
        container.register { Firestore.firestore() }
        container.register { Storage.storage() }
        container.register { DataProviderImpl(db: container.resolve()) }.as(DataProvider.self)
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

}

extension DIContainer {

    public static let shared = DIContainer()

}

