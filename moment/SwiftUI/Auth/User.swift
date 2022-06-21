class NewUser: CustomStringConvertible {

    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }

    var description: String {
        "NewUser(uid: \(uid), email: \(email), displayName: \(displayName))"
    }

}
