import UIKit

class FeedTableCell: UITableViewCell, UIScrollViewDelegate {

    private static let formatString: String = NSLocalizedString("likes count", comment: "Likes count string format to be found in Localized.stringsdict")

    private var unsplashImage: UnsplashImage
    private let contentWidth: Double
    private let margin: Double
    private var likeCounter: UILabel?
    private var likeButton: HeartButton?
    private let spinner = SpinnerViewController()
    private var mainImageView: UIImageView?
    private var heartLayer: CAShapeLayer?
    private let share: ((UIImage) -> Void)?
    private let comment: (() -> Void)?

    init(share: ((UIImage) -> Void)?,
         comment: (() -> Void)?,
         unsplashImage: inout UnsplashImage,
         contentWidth: Double,
         margin: Double) {
        self.share = share
        self.comment = comment
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
        addSpinnerSubview(imageHeight: imageHeight)
        addNicknameSubview()
        addLikeButtonAndLikeCounterSubviews(imageHeight: imageHeight)
        addPortraitSubview()
        addMainImageAndShareButtonSubviews(imageHeight: imageHeight, imageRatio: imageRatio)
        addCommentButtonSubview(imageHeight: imageHeight)
    }

    private func addSpinnerSubview(imageHeight: Double) {
        contentView.addSubview(spinner.view)
        spinner.view.layer.cornerRadius = 8.0
        spinner.view.frame = CGRect(x: margin, y: 50, width: contentWidth, height: imageHeight)
    }

    private func addPortraitSubview() {
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData: Data = try Data(contentsOf: URL(string: self.unsplashImage.user.profileImage.large)!)
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    let portraitView = UIImageView(image: image)
                    portraitView.frame = CGRect(x: self.margin, y: 10, width: 30, height: 30)
                    portraitView.layer.masksToBounds = false
                    portraitView.layer.cornerRadius = 15
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
        nicknameLabelView.frame = CGRect(x: (margin * 2) + 30, y: 10, width: contentWidth - 50, height: 30)
        contentView.addSubview(nicknameLabelView)
    }

    private func addMainImageAndShareButtonSubviews(imageHeight: Double, imageRatio: Double) {
        let configure: (UIView?) -> Void = { view in
            view?.layer.cornerRadius = 8.0
            view?.contentMode = .scaleAspectFit
            view?.clipsToBounds = true
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let imageData: Data = try Data(contentsOf: URL(string: self.unsplashImage.urls.regular)!)
                DispatchQueue.main.async {
                    let shareButton = UIButton(type: .custom)
                    shareButton.setImage(UIImage(named: "share"), for: UIControl.State.normal)
                    shareButton.frame = CGRect(x: (self.margin * 3) + 60, y: imageHeight + 60, width: 30, height: 30)
                    let image = UIImage(data: imageData)
                    self.mainImageView = UIImageView(image: image)
                    self.mainImageView?.frame = CGRect(x: 0, y: 0, width: self.contentWidth, height: imageHeight)
                    shareButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
                        guard let image = image else {
                            return
                        }
                        self.share?(image)
                    }
                    self.contentView.addSubview(shareButton)
                    configure(self.mainImageView!)
                    self.addBezierLayer()
                    let scrollView = UIScrollView()
                    scrollView.frame = CGRect(x: self.margin, y: 50, width: self.contentWidth, height: imageHeight)
                    scrollView.delegate = self
                    scrollView.minimumZoomScale = 1.0
                    scrollView.maximumZoomScale = 10.0
                    scrollView.layer.cornerRadius = 8.0
                    scrollView.alwaysBounceVertical = false
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.showsHorizontalScrollIndicator = false
                    scrollView.showsVerticalScrollIndicator = false
                    scrollView.addSubview(self.mainImageView!)
                    self.spinner.view.removeFromSuperview()
                    self.contentView.addSubview(scrollView)
                    self.mainImageView!.isUserInteractionEnabled = true
                    self.mainImageView!.setOnDoubleClickListener {
                        guard !self.unsplashImage.likedByUser else {
                            return
                        }
                        self.heartLayer?.flash(duration: 0.2)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        self.likePressed()
                        self.likeButton?.flipLikedState()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    let label = UILabel()
                    label.frame = CGRect(x: self.margin, y: 50, width: self.contentWidth, height: imageHeight)
                    label.text = "Couldn't load image. Please try again later."
                    label.textAlignment = .center
                    label.textColor = .gray
                    configure(label)
                    self.spinner.view.removeFromSuperview()
                    self.contentView.addSubview(label)
                }
            }
        }
    }

    private func addCommentButtonSubview(imageHeight: Double) {
        let commentButton = UIButton(type: .custom)
        commentButton.setImage(UIImage(named: "comment"), for: UIControl.State.normal)
        commentButton.frame = CGRect(x: (margin * 2) + 30, y: imageHeight + 60, width: 30, height: 30)
        commentButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.comment?()
        }
        contentView.addSubview(commentButton)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mainImageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(0.0, animated: true)
    }

    private func addLikeButtonAndLikeCounterSubviews(imageHeight: Double) {
        likeCounter = UILabel()
        guard let likeCounter = likeCounter else {
            return
        }
        likeCounter.text = likeText(likes: unsplashImage.likes)
//        likeCounter.font = UIFont(name: likeCounter.font.fontName, size: 15)
        likeCounter.frame = CGRect(x: margin, y: imageHeight + 100, width: contentWidth, height: 20)
        contentView.addSubview(likeCounter)
        likeButton = HeartButton()
        guard let likeButton = likeButton else {
            return
        }
        likeButton.setLiked(value: unsplashImage.likedByUser)
        likeButton.frame = CGRect(x: margin, y: imageHeight + 60, width: 30, height: 30)
        likeButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.likePressed()
            likeButton.flipLikedState()
        }
        contentView.addSubview(likeButton)
    }

    private func likePressed() {
        if unsplashImage.likedByUser {
            unsplashImage.likedByUser = false
            unsplashImage.likes = unsplashImage.likes - 1
            likeCounter?.text = likeText(likes: unsplashImage.likes)
        } else {
            unsplashImage.likedByUser = true
            unsplashImage.likes = unsplashImage.likes + 1
            likeCounter?.text = likeText(likes: unsplashImage.likes)
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
        guard let heartLayer = heartLayer else {
            return
        }
        heartLayer.fillColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        heartLayer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        heartLayer.path = bezier.cgPath
        heartLayer.opacity = 0
        heartLayer.shadowOffset = .zero
        heartLayer.shadowRadius = 2
        heartLayer.shadowOpacity = 1
        heartLayer.shadowPath = heartLayer.path
        mainImageView?.layer.addSublayer(heartLayer)
    }

}
