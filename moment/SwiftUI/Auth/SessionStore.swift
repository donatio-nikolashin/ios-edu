import SwiftUI
import Firebase
import FirebaseAuth

class SessionStore: ObservableObject {

    private var handle: AuthStateDidChangeListenerHandle?

    @Published var session: NewUser?

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.session = NewUser(
                        uid: user.uid,
                        displayName: user.displayName,
                        email: user.email
                )
            } else {
                self.session = nil
            }
        }
    }
    
    func authenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func signUp(email: String,
                password: String,
                handler: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }

    func signIn(email: String,
                password: String,
            handler: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }

    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            session = nil
            return true
        } catch {
            return false
        }
    }

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

}
