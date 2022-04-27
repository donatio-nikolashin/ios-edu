import UIKit

class HeartButton: UIButton {

    private var isLiked = false

    private let unlikedImage = UIImage(named: "like_empty")
    private let likedImage = UIImage(named: "like_filled")

    private let unlikedScale: CGFloat = 0.7
    private let likedScale: CGFloat = 1.3

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setImage(unlikedImage, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func flipLikedState() {
        isLiked = !isLiked
        animate()
    }

    public func setLiked(value: Bool) {
        isLiked = value
        setImage(value ? likedImage : unlikedImage, for: .normal)
    }

    private func animate() {
        UIView.animate(withDuration: 0.1, animations: {
                    let newImage = self.isLiked ? self.likedImage : self.unlikedImage
                    let newScale = self.isLiked ? self.likedScale : self.unlikedScale
                    self.transform = self.transform.scaledBy(x: newScale, y: newScale)
                    self.setImage(newImage, for: .normal)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1, animations: {
                                self.transform = CGAffineTransform.identity
                            })
                })
    }

}