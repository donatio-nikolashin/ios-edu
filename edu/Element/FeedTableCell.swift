import UIKit

class FeedTableCell: UITableViewCell {

    private static let formatString: String = NSLocalizedString("likes count", comment: "Likes count string format to be found in Localized.stringsdict")

    private var unsplashImage: UnsplashImage
    private let contentWidth: Double
    private let margin: Double
    private var likeCounter: UILabel? = nil
    private var likeButton: HeartButton? = nil
    private let share: (UIActivityViewController) -> Void

    init(share: @escaping (UIActivityViewController) -> Void, unsplashImage: inout UnsplashImage, contentWidth: Double, margin: Double) {
        self.share = share
        self.unsplashImage = unsplashImage
        self.contentWidth = contentWidth
        self.margin = margin
        super.init(style: CellStyle.default, reuseIdentifier: nil)
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
        addPortraitSubview()
        addNicknameSubview()
        addMainImageSubviewAndShareButton(imageHeight: imageHeight, imageRatio: imageRatio)
        addLikeButtonAndLikeCounterSubviews(imageHeight: imageHeight)
        addDescription(imageHeight: imageHeight)
    }

    private func addPortraitSubview() {
        do {
            let imageData: Data = try Data(contentsOf: URL(string: unsplashImage.user.profile_image.large)!)
            let image = UIImage(data: imageData)
            let portraitView = UIImageView(image: image)
            portraitView.frame = CGRect(x: margin, y: 10, width: 40, height: 40)
            portraitView.layer.masksToBounds = false
            portraitView.layer.cornerRadius = 20
            portraitView.clipsToBounds = true
            contentView.addSubview(portraitView)
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    private func addNicknameSubview() {
        let nicknameLabelView = UILabel()
        nicknameLabelView.text = unsplashImage.user.username
        nicknameLabelView.frame = CGRect(x: (margin * 2) + 40, y: 10, width: contentWidth - 60, height: 40)
        contentView.addSubview(nicknameLabelView)
    }

    private func addMainImageSubviewAndShareButton(imageHeight: Double, imageRatio: Double) {
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(UIImage(named: "share_btn"), for: UIControl.State.normal)
        shareButton.frame = CGRect(x: contentWidth - margin - 20, y: imageHeight + 70, width: 40, height: 40)
        let mainImageView: UIView
        do {
            let imageData: Data = try Data(contentsOf: URL(string: unsplashImage.urls.regular)!)
            let image = UIImage(data: imageData)
            mainImageView = UIImageView(image: image)
            shareButton.setOnClickListener(for: UIControl.Event.touchUpInside) {
                        let items = [image!]
                        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.share(ac)
                    }
            contentView.addSubview(shareButton)
        } catch {
            let label = UILabel()
            label.text = "Couldn't load image. Please try again later."
            label.textAlignment = .center
            label.textColor = .gray
            mainImageView = label
        }
        let imageHeight = contentWidth * imageRatio
        mainImageView.frame = CGRect(x: margin, y: 60, width: contentWidth, height: imageHeight)
        mainImageView.layer.cornerRadius = 8.0
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.clipsToBounds = true
        contentView.addSubview(mainImageView)
        mainImageView.isUserInteractionEnabled = true
        mainImageView.setOnDoubleClickListener {
                    self.likePressed(likeCounter: self.likeCounter!, likeButton: self.likeButton!)
                    self.likeButton!.flipLikedState()
                }
    }

    private func addLikeButtonAndLikeCounterSubviews(imageHeight: Double) {
        likeCounter = UILabel()
        likeCounter!.text = likeText(likes: unsplashImage.likes)
        likeCounter!.frame = CGRect(x: (margin * 2) + 40, y: imageHeight + 70, width: contentWidth - 60, height: 40)
        contentView.addSubview(likeCounter!)
        likeButton = HeartButton()
        likeButton!.frame = CGRect(x: margin, y: imageHeight + 70, width: 40, height: 40)
        likeButton!.setOnClickListener(for: UIControl.Event.touchUpInside) {
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

}
