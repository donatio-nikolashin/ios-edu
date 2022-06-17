import UIKit
import SwiftLazy
import FirebaseAuth
import FirebaseFirestore
import DITranquillity
import YPImagePicker

class FeedTableViewController: UITableViewController {

    private let photoFirestore: PhotoFirestore
    private let photoProvider: PhotoProvider
    private let addPostViewController: Lazy<AddPostViewController>
    private let commentViewController: Lazy<CommentViewController>
    private let loginViewController: Lazy<LoginViewController>

    init(photoFirestore: PhotoFirestore,
         photoProvider: PhotoProvider,
         addPostViewController: Lazy<AddPostViewController>,
         commentViewController: Lazy<CommentViewController>,
         loginViewController: Lazy<LoginViewController>) {
        self.photoFirestore = photoFirestore
        self.photoProvider = photoProvider
        self.addPostViewController = addPostViewController
        self.commentViewController = commentViewController
        self.loginViewController = loginViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var photos: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feed"
        view?.overrideUserInterfaceStyle = .light
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorColor = .white
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(fetchDataForce), for: .valueChanged)
        fetchData(force: false)
    }

    @objc func fetchDataForce() {
        fetchData(force: true)
    }

    override func viewDidLayoutSubviews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPhotoTapped))
    }

    @objc private func logOutTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        do {
            try FirebaseAuth.Auth.auth().signOut()
            navigationController?.setViewControllers([loginViewController.value], animated: true)
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    @objc private func addPhotoTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        var config = YPImagePickerConfiguration()
        config.hidesStatusBar = false
        config.startOnScreen = YPPickerScreen.library
        config.albumName = "Moment"
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                picker.pushViewController(self.addPostViewController.value, animated: false)
                self.addPostViewController.value.setUp(image: photo.image) { description in
                    picker.dismiss(animated: true, completion: nil)
                    self.photoFirestore.publish(image: photo.image, description: description) { metadata, error in
                        if error != nil {
                            print("Unexpected error: \(error!).")
                            return
                        }
                        self.fetchData(force: true)
                    }
                }
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
        }
        present(picker, animated: true, completion: nil)
    }

    private func fetchData(force: Bool) {
        photoProvider.fetch(force: force) { photos, error in
            guard let photos = photos else {
                print("Unexpected error: \(error!).")
                return
            }
            photos.forEach { photo in
                if !self.photos.contains(where: { exising in exising.id == photo.id }) {
                    if photo.descr != nil {
                        photo.comments.insert(Comment(comment: photo.descr!, user: photo.user, commentByUser: true), at: 0)
                    }
                    self.photos.insert(photo, at: 0)
                }
            }
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let unsplashImage = photos[indexPath.row]
        let contentWidth = view.bounds.width * 0.95
        let ratio = unsplashImage.height / unsplashImage.width
        return (contentWidth * ratio) + 130
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contentWidth = view.bounds.width * 0.95
        let margin = (view.bounds.width - contentWidth) / 2.0
        return FeedTableCell(
                share: { image in
                    let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    self.present(ac, animated: true)
                },
                comment: {
                    self.navigationController?.pushViewController(self.commentViewController.value, animated: true)
                    self.commentViewController.value.setUp(photo: self.photos[indexPath.row], comments: self.photos[indexPath.row].comments) { comment in
                        self.photos[indexPath.row].comments.append(comment)
                    }
                },
                photo: &photos[indexPath.row],
                contentWidth: contentWidth,
                margin: margin
        )
    }

}
