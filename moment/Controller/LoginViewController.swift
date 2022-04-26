import UIKit
import FirebaseAuth
import DITranquillity

public class LoginViewController: UIViewController {

    private let feedTableViewController: FeedTableViewController = DIContainer.shared.resolve()
    private let registrationViewController: RegistrationViewController = DIContainer.shared.resolve()

    private let signInLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Log In"
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

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "error"
        label.textColor = .red
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign in", for: .normal)
        return button
    }()

    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.setTitle("Haven't got account yet? Sign up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        return button
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view?.overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        if FirebaseAuth.Auth.auth().currentUser != nil {
            navigationController?.setViewControllers([FeedTableViewController()], animated: true)
            return
        }
        view.addSubview(signInLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(errorLabel)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.text = nil
        passwordField.text = nil
        errorLabel.text = nil
        errorLabel.isHidden = true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 80)
        emailField.frame = CGRect(x: 20, y: signInLabel.frame.origin.y + signInLabel.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.frame.origin.y + emailField.frame.size.height + 10, width: view.frame.width - 40, height: 50)
        errorLabel.frame = CGRect(x: 20, y: passwordField.frame.origin.y + passwordField.frame.size.height + 8, width: view.frame.width - 40, height: 14)
        signInButton.frame = CGRect(x: 20, y: errorLabel.frame.origin.y + errorLabel.frame.size.height + 8, width: view.frame.width - 40, height: 52)
        signUpButton.frame = CGRect(x: 20, y: signInButton.frame.origin.y + signInButton.frame.size.height + 20, width: view.frame.width - 40, height: 14)
    }

    @objc func didTapSignInButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty
        else {
            errorLabel.text = "All fields should be filled"
            errorLabel.isHidden = false
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            guard error == nil else {
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.isHidden = false
                return
            }
            self.errorLabel.text = nil
            self.errorLabel.isHidden = true
            self.emailField.resignFirstResponder()
            self.passwordField.resignFirstResponder()
            self.navigationController?.setViewControllers([self.feedTableViewController], animated: true)
        })
    }

    @objc func didTapSignUpButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        navigationController?.pushViewController(registrationViewController, animated: false)
    }

}