import UIKit
import YPImagePicker

class AddPostViewController: UIViewController {

    private var publish: (String?) -> Void = { description in }

    private let imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private let descriptionTextField: UITextField = {
        let field = UITextField()
        field.textAlignment = .left
        field.placeholder = "Add description..."
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Post"
        view?.overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(descriptionTextField)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextField.text = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .plain, target: self, action: #selector(didTapPublishButton))
    }

    func setUp(image: UIImage, publish: @escaping (String?) -> Void) {
        self.publish = publish
        let ratio = image.size.width / image.size.height
        let width = view.bounds.width / 4
        imageView.image = image
        imageView.frame = CGRect(x: 10, y: 10, width: width, height: width / ratio)
        descriptionTextField.frame = CGRect(x: 20 + width, y: 10, width: view.bounds.width - width - 20, height: width / ratio)
    }

    @objc private func didTapPublishButton() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        publish(descriptionTextField.text)
    }

}
