import UIKit
import SwiftLazy
import FirebaseAuth
import FirebaseFirestore
import DITranquillity

class RegistrationViewController: UIViewController {

    private let firestore: Firestore
    private let feedTableViewController: Lazy<FeedTableViewController>

    init(firestore: Firestore, feedTableViewController: Lazy<FeedTableViewController>) {
        self.feedTableViewController = feedTableViewController
        self.firestore = firestore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let registrationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Registration"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address"
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.black.cgColor
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let confirmPasswordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Confirm password"
        field.autocapitalizationType = .none
        field.layer.borderWidth = 1
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.black.cgColor
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "error"
        label.textColor = .red
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign Up", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view?.overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        view.addSubview(registrationLabel)
        view.addSubview(emailField)
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(errorLabel)
        view.addSubview(confirmPasswordField)
        view.addSubview(signUpButton)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: self, action: #selector(backTapped))
        addKeyboardPositionObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.text = nil
        passwordField.text = nil
        confirmPasswordField.text = nil
        errorLabel.text = nil
        errorLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resetFrames()
    }

    private func resetFrames() {
        registrationLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 80)
        emailField.frame = CGRect(x: 20, y: registrationLabel.frame.origin.y + registrationLabel.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        usernameField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: usernameField.frame.origin.y + usernameField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        confirmPasswordField.frame = CGRect(x: 20, y: passwordField.frame.origin.y + passwordField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        errorLabel.frame = CGRect(x: 20, y: confirmPasswordField.frame.origin.y + confirmPasswordField.frame.size.height + 8, width: view.frame.width - 40, height: 14)
        signUpButton.frame = CGRect(x: 20, y: errorLabel.frame.origin.y + errorLabel.frame.size.height + 8, width: view.frame.width - 40, height: 52)
    }

    private func adjustFramesForKeyboard(keyboardFrame: CGRect) {
        signUpButton.frame = CGRect(x: 20, y: view.frame.height - keyboardFrame.height - 72, width: view.frame.width - 40, height: 52)
        errorLabel.frame = CGRect(x: 20, y: signUpButton.frame.origin.y - 14 - 8, width: view.frame.width - 40, height: 14)
        confirmPasswordField.frame = CGRect(x: 20, y: errorLabel.frame.origin.y - 50 - 8, width: view.frame.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: confirmPasswordField.frame.origin.y - 50 - 10, width: view.frame.width - 40, height: 50)
        usernameField.frame = CGRect(x: 20, y: passwordField.frame.origin.y - 50 - 10, width: view.frame.width - 40, height: 50)
        emailField.frame = CGRect(x: 20, y: usernameField.frame.origin.y - 50 - 10, width: view.frame.width - 40, height: 50)
        registrationLabel.frame = CGRect(x: 0, y: emailField.frame.origin.y - 80 - 10, width: view.frame.width, height: 80)
    }

    @objc func didTapSignUpButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let email = emailField.text, !email.isEmpty,
              let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty
        else {
            errorLabel.text = "All fields should be filled"
            errorLabel.isHidden = false
            return
        }
        guard password == confirmPassword else {
            errorLabel.text = "Password and confirm password does not match"
            errorLabel.isHidden = false
            return
        }
        firestore.collection("users").whereField("username", isEqualTo: username).getDocuments(completion: { snapshot, error in
            guard error == nil else {
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.isHidden = false
                return
            }
            if snapshot?.isEmpty == true {
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
                    guard error == nil else {
                        self.errorLabel.text = error?.localizedDescription
                        self.errorLabel.isHidden = false
                        return
                    }
                    self.firestore.collection("users").document(result!.user.uid).setData(["username": username], merge: false)
                    self.errorLabel.text = nil
                    self.errorLabel.isHidden = true
                    self.emailField.resignFirstResponder()
                    self.passwordField.resignFirstResponder()
                    self.navigationController?.setViewControllers([self.feedTableViewController.value], animated: true)
                })
            } else {
                self.errorLabel.text = "That username is taken. Try another"
                self.errorLabel.isHidden = false
                return
            }
        })
    }

    @objc func backTapped(sender: UIBarButtonItem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navigationController?.popViewController(animated: false)
    }

}

extension RegistrationViewController {

    func addKeyboardPositionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            adjustFramesForKeyboard(keyboardFrame: keyboardFrame)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        resetFrames()
    }

}
