import UIKit
import FirebaseAuth
import FirebaseFirestore
import DITranquillity

class FeedTableViewController: UITableViewController {

    private let dataProvider: DataProvider = DIContainer.shared.resolve()

    private var photos: [Photo] = []
    private var initialFetch = true

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
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutTapped))
    }

    @objc private func logOutTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        do {
            try FirebaseAuth.Auth.auth().signOut()
            navigationController?.setViewControllers([LoginViewController()], animated: true)
        } catch {
            print("unable to log out")
        }
    }

    @objc private func fetchData() {
        Task.init {
            let photos = await dataProvider.fetchPhotos()
            photos.forEach { photo in
                if !self.photos.contains(where: { exising in exising.id == photo.id }) {
                    if photo.descr != nil {
                        photo.comments.insert(Comment(comment: photo.descr!, user: photo.user), at: 0)
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
                    let commentViewController = CommentViewController()
                    self.navigationController?.pushViewController(commentViewController, animated: true)
                    commentViewController.setComments(self.photos[indexPath.row].comments) { comment in
                        self.photos[indexPath.row].comments.append(comment)
                    }
                },
                photo: &photos[indexPath.row],
                contentWidth: contentWidth,
                margin: margin
        )
    }

}
