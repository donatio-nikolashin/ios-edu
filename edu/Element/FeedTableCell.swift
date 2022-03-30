import UIKit

class FeedTableCell: UITableViewCell, UIScrollViewDelegate {

    private static let formatString: String = NSLocalizedString("likes count", comment: "Likes count string format to be found in Localized.stringsdict")

    private var unsplashImage: UnsplashImage
    private let contentWidth: Double
    private let margin: Double
    private var likeCounter: UILabel? = nil
    private var likeButton: HeartButton? = nil
    private var mainImageView: UIImageView? = nil
    private var heartLayer: CAShapeLayer? = nil
    private let share: (UIActivityViewController) -> Void

    init(share: @escaping (UIActivityViewController) -> Void, unsplashImage: inout UnsplashImage, contentWidth: Double, margin: Double) {
        self.share = share
        self.unsplashImage = unsplashImage
        self.contentWidth = contentWidth
        self.margin = margin
        super.init(style: CellStyle.default, reuseIdentifier: nil)
        backgroundColor = .white
        selectionStyle = .none
        contentView.isUserInteractionEnabled = true
        reload()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reload() {
        let imageRatio: Double = unsplashImage.height / unsplashImage.width
        let imageHeight = contentWidth * imageRatio
        addNicknameSubview()
        addLikeButtonAndLikeCounterSubviews(imageHeight: imageHeight)
        addDescription(imageHeight: imageHeight)
        addPortraitSubview()
        addMainImageSubviewAndShareButton(imageHeight: imageHeight, imageRatio: imageRatio)
    }

    private func addPortraitSubview() {
        DispatchQueue.global().async {
                    do {
                        let imageData: Data = try Data(contentsOf: URL(string: self.unsplashImage.user.profile_image.large)!)
                        DispatchQueue.main.async {
                                    let image = UIImage(data: imageData)
                                    let portraitView = UIImageView(image: image)
                                    portraitView.frame = CGRect(x: self.margin, y: 10, width: 40, height: 40)
                                    portraitView.layer.masksToBounds = false
                                    portraitView.layer.cornerRadius = 20
                                    portraitView.clipsToBounds = true
                                    self.contentView.addSubview(portraitView)
                                }
                    } catch {
                        print("Unexpected error: \(error).")
                    }
                }
    }

    private func addNicknameSubview() {
        let nicknameLabelView = UILabel()
        nicknameLabelView.text = unsplashImage.user.username
        nicknameLabelView.frame = CGRect(x: (margin * 2) + 40, y: 10, width: contentWidth - 60, height: 40)
        contentView.addSubview(nicknameLabelView)
    }

    private func addMainImageSubviewAndShareButton(imageHeight: Double, imageRatio: Double) {
        let configure: (UIView) -> Void = { view in
            view.frame = CGRect(x: 0, y: 0, width: self.contentWidth, height: imageHeight)
            view.layer.cornerRadius = 8.0
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
        }
        DispatchQueue.global().async {
                    do {
                        let imageData: Data = try Data(contentsOf: URL(string: self.unsplashImage.urls.regular)!)
                        DispatchQueue.main.async {
                                    let shareButton = UIButton(type: .custom)
                                    shareButton.setImage(UIImage(named: "share_btn"), for: UIControl.State.normal)
                                    shareButton.frame = CGRect(x: self.contentWidth - self.margin - 20, y: imageHeight + 70, width: 40, height: 40)
                                    let image = UIImage(data: imageData)
                                    self.mainImageView = UIImageView(image: image)
                                    shareButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
                                                let items = [image!]
                                                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                                                self.share(ac)
                                            }
                                    self.contentView.addSubview(shareButton)
                                    configure(self.mainImageView!)
                                    self.addBezierLayer()
                                    let scrollView = UIScrollView()
                                    scrollView.frame = CGRect(x: self.margin, y: 60, width: self.contentWidth, height: imageHeight)
                                    scrollView.delegate = self
                                    scrollView.minimumZoomScale = 1.0
                                    scrollView.maximumZoomScale = 10.0
                                    scrollView.layer.cornerRadius = 8.0
                                    scrollView.alwaysBounceVertical = false
                                    scrollView.alwaysBounceHorizontal = false
                                    scrollView.showsHorizontalScrollIndicator = false
                                    scrollView.showsVerticalScrollIndicator = false
                                    scrollView.addSubview(self.mainImageView!)
                                    self.contentView.addSubview(scrollView)
                                    self.mainImageView!.isUserInteractionEnabled = true
                                    self.mainImageView!.setOnDoubleClickListener {
                                                self.heartLayer?.flash(duration: 0.2)
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                if !self.unsplashImage.liked_by_user {
                                                    self.likePressed(likeCounter: self.likeCounter!, likeButton: self.likeButton!)
                                                    self.likeButton!.flipLikedState()
                                                }
                                            }
                                }
                    } catch {
                        let label = UILabel()
                        label.text = "Couldn't load image. Please try again later."
                        label.textAlignment = .center
                        label.textColor = .gray
                        configure(label)
                        self.contentView.addSubview(label)
                    }
                }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mainImageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(0.0, animated: true)
    }

    private func addLikeButtonAndLikeCounterSubviews(imageHeight: Double) {
        likeCounter = UILabel()
        likeCounter!.text = likeText(likes: unsplashImage.likes)
        likeCounter!.frame = CGRect(x: (margin * 2) + 40, y: imageHeight + 70, width: contentWidth - 60, height: 40)
        contentView.addSubview(likeCounter!)
        likeButton = HeartButton()
        likeButton!.setLiked(value: unsplashImage.liked_by_user)
        likeButton!.frame = CGRect(x: margin, y: imageHeight + 70, width: 40, height: 40)
        likeButton!.setOnClickListener(for: UIControl.Event.touchUpInside) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    self.likePressed(likeCounter: self.likeCounter!, likeButton: self.likeButton!)
                    self.likeButton!.flipLikedState()
                }
        contentView.addSubview(likeButton!)
    }

    private func addDescription(imageHeight: Double) {
        if (unsplashImage.description != nil) {
            let descriptionView = UILabel()
            descriptionView.text = unsplashImage.description!
            descriptionView.textColor = .black
            descriptionView.frame = CGRect(x: margin, y: imageHeight + 120, width: contentWidth, height: 40)
            contentView.addSubview(descriptionView)
        }
    }

    private func likePressed(likeCounter: UILabel, likeButton: UIButton) {
        if unsplashImage.liked_by_user {
            unsplashImage.liked_by_user = false
            unsplashImage.likes = unsplashImage.likes - 1
            likeCounter.text = likeText(likes: unsplashImage.likes)
        } else {
            unsplashImage.liked_by_user = true
            unsplashImage.likes = unsplashImage.likes + 1
            likeCounter.text = likeText(likes: unsplashImage.likes)
        }
    }

    private func likeText(likes: Int) -> String {
        let localized: String = String.localizedStringWithFormat(FeedTableCell.formatString, likes)
        return String(likes) + " " + localized
    }

    func addBezierLayer() {
        let bezier = UIBezierPath()
        bezier.drawHeart(originalRect: mainImageView!.frame, scale: 0.2)
        heartLayer = CAShapeLayer()
        heartLayer!.fillColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        heartLayer!.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        heartLayer!.path = bezier.cgPath
        heartLayer!.opacity = 0
        heartLayer!.shadowOffset = .zero
        heartLayer!.shadowRadius = 2
        heartLayer!.shadowOpacity = 1
        heartLayer!.shadowPath = heartLayer!.path
        mainImageView?.layer.addSublayer(heartLayer!)
    }

}
