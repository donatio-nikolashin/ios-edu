import UIKit

extension CALayer {

    func flash(duration: TimeInterval) -> Void {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.fromValue = NSNumber(value: 0)
        flash.toValue = NSNumber(value: 1)
        flash.duration = duration
        flash.autoreverses = true
        removeAnimation(forKey: "flashAnimation")
        add(flash, forKey: "flashAnimation")
        opacity = 0
    }

}