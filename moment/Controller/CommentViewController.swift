import UIKit

class CommentViewController: UIViewController {

    private var comments: [UnsplashImageComment] = []
    private var appendComment: ((UnsplashImageComment) -> Void)?

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CommentTableCell.self, forCellReuseIdentifier: "CommentTableCell")
        table.backgroundColor = .white
        table.separatorColor = .white
        table.allowsSelection = false
        return table
    }()

    private let textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .gray.withAlphaComponent(0.1)
        field.textAlignment = .left
        field.placeholder = "Add comment..."
        field.layer.cornerRadius = 5
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: field, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .down
        field.addGestureRecognizer(swipeGestureRecognizerDown)
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Send  ", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        textField.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comments"
        view?.overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.dataSource = self
//        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200.0
        view.addSubview(textField)
        textField.delegate = self
        textField.rightView = sendButton
        textField.rightViewMode = .whileEditing
        sendButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
            if !(self.textField.text?.isEmpty ?? true) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.sendComment()
                self.view.endEditing(true)
            }
        }
        resetFrames()
        addKeyboardPositionObserver()
    }

    private func resetFrames() {
        let margin = 10.0
        textField.frame = CGRect(x: margin, y: view.frame.height * 0.9 + margin, width: view.frame.width - margin * 2, height: view.frame.height * 0.1 - margin * 2)
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.9)
    }

    private func adjustFramesForKeyboard(keyboardFrame: CGRect) {
        let margin = 10.0
        textField.frame = CGRect(x: margin, y: view.frame.height * 0.9 - keyboardFrame.height + margin, width: view.frame.width - margin * 2, height: view.frame.height * 0.1 - margin * 2)
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.9 - keyboardFrame.height)
    }

    public func setComments(_ comments: [UnsplashImageComment]?, appendComment: @escaping (UnsplashImageComment) -> Void) {
        self.appendComment = appendComment
        if let comments = comments {
            self.comments = comments
            tableView.reloadData()
        }
    }

    private func sendComment() {
        if let comment = textField.text {
            let unsplashComment = UnsplashImageComment(comment)
            comments.append(unsplashComment)
            appendComment?(unsplashComment)
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: comments.count - 1, section: 0), at: .top, animated: false)
            textField.text = nil
        }
    }

}

extension CommentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count == 0 ? 1 : comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentTableCell", for: indexPath) as! CommentTableCell
        if comments.count > 0 {
            cell.setComment(comments[indexPath.row])
        } else {
            cell.textLabel?.text = "Be first to comment..."
            cell.textLabel?.textColor = .gray
            cell.textLabel?.textAlignment = .center
        }
        return cell
    }

}

//extension CommentViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        50
//    }
//
//}

extension CommentViewController {

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

extension CommentViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment()
        return view.endEditing(true)
    }

}