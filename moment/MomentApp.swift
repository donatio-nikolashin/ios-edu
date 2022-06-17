import SwiftUI
import Firebase
import DITranquillity

@main
struct MomentApp: App {

    init() {
        FirebaseApp.configure()
        DIContainer.shared.register { SessionStore() }.lifetime(.single)
    }

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(DIContainer.shared.resolve() as SessionStore)
        }
    }

}

extension DIContainer {

    public static let shared = DIContainer()

}
