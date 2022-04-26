import UIKit

class CommentTableCell: UITableViewCell {

    private var comment: UnsplashImageComment?

    public func setComment(_ comment: UnsplashImageComment) {
        self.comment = comment
        do {
            let imageData: Data = try Data(contentsOf: URL(string: comment.user.profileImage.large)!)
            let userComment = comment.user.username == UnsplashUser.ME.username
            imageView?.image = (userComment ? UIImage(data: imageData) : UIImage(named: "avatar"))?.resized(to: CGSize(width: 40, height: 40))
            imageView?.layer.masksToBounds = false
            imageView?.layer.cornerRadius = 20
            imageView?.clipsToBounds = true
            textLabel?.text = comment.user.username + ": " + comment.comment
            textLabel?.numberOfLines = 0
            textLabel?.preferredMaxLayoutWidth = contentView.bounds.size.width
            textLabel?.lineBreakMode = .byWordWrapping
            textLabel?.textColor = .black
            textLabel?.textAlignment = .left
            textLabel?.sizeToFit()
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        mirrorCellIf(required: comment?.user.username == UnsplashUser.ME.username)
    }

    private func mirrorCellIf(required: Bool) {
        if required {
            if var imageViewFrame = imageView?.frame {
                imageViewFrame.origin.x = contentView.bounds.size.width - (imageViewFrame.size.width + imageViewFrame.origin.x)
                imageView?.frame = imageViewFrame
            }
            if var textFrame = textLabel?.frame {
                textFrame.origin.x = contentView.bounds.size.width - (textFrame.origin.x + textFrame.size.width)
                textLabel?.frame = textFrame
                textLabel?.textAlignment = .right
            }
        }
    }

}