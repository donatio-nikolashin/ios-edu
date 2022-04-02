import UIKit

class FeedTableViewController: UITableViewController  {

    private var images: [UnsplashImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Unsplash"
        if #available(iOS 13.0, *) {
            view?.overrideUserInterfaceStyle = .light
        }
        navigationController?.isNavigationBarHidden = false
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorColor = .white
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        initLoading()
    }

    private func initLoading() {
        let apiHost = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_HOST") as! String
        let accessKey = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String
        let count = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_PHOTOS_COUNT") as? String
        let client = APIClient(host: apiHost)
        Task.init {
                    do {
                        images = try await client.send(
                                        .get("/photos/random",
                                                query: [
                                                    ("client_id", accessKey),
                                                    ("count", count),
                                                    ("orientation", "squarish")
                                                ]
                                        )).value
                        tableView.reloadData()
                    } catch {
                        print("Unexpected error: \(error).")
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
        return (contentWidth * ratio) + (unsplashImage.description != nil ? 170 : 130)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contentWidth = view.bounds.width * 0.95
        let margin = (view.bounds.width - contentWidth) / 2.0
        return FeedTableCell(
                share: { image in
                    let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    self.present(ac, animated: true)
                },
                unsplashImage: &images[indexPath.row],
                contentWidth: contentWidth,
                margin: margin
        )
    }

}
