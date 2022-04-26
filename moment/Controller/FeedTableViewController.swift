import UIKit

class FeedTableViewController: UITableViewController {

    private var images: [UnsplashImage] = []
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

    @objc private func fetchData() {
        let client = APIClient(host: Config.unsplashApiHost)
        Task.init {
            do {
                (try await client.send(
                                .get("/photos/random",
                                        query: [
                                            ("client_id", Config.unsplashAccessKey),
                                            ("count", initialFetch ? Config.unsplashFetchCount : "4"),
                                            ("orientation", "squarish")
                                        ]
                                ))
                        .value as [UnsplashImage])
                        .forEach { image in
                            if image.description != nil {
                                image.comments = [UnsplashImageComment(comment: image.description!, user: image.user)]
                            }
                            if !images.contains(where: { exising in exising.id == image.id }) {
                                images.insert(image, at: 0)
                            }
                        }
                if initialFetch == true {
                    initialFetch = false
                }
            } catch {
                print("Unexpected error: \(error).")
            }
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        images.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let unsplashImage = images[indexPath.row]
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
                    commentViewController.setComments(self.images[indexPath.row].comments) { comment in
                        if self.images[indexPath.row].comments == nil {
                            self.images[indexPath.row].comments = [comment]
                        } else {
                            self.images[indexPath.row].comments?.append(comment)
                        }
                    }
                },
                unsplashImage: &images[indexPath.row],
                contentWidth: contentWidth,
                margin: margin
        )
    }

}
