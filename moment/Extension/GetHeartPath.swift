import UIKit

public extension UIBezierPath {

    func drawHeart(originalRect: CGRect, scale: Double) -> Void {
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        move(to: CGPoint(x: originalRect.size.width / 2, y: scaledRect.origin.y + scaledRect.size.height))
        addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height / 4)),
                controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width / 2), y: scaledRect.origin.y + (scaledRect.size.height * 3 / 4)),
                controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height / 2)))
        addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width / 4), y: scaledRect.origin.y + (scaledRect.size.height / 4)),
                radius: (scaledRect.size.width / 4),
                startAngle: CGFloat(Double.pi),
                endAngle: 0,
                clockwise: true)
        addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3 / 4), y: scaledRect.origin.y + (scaledRect.size.height / 4)),
                radius: (scaledRect.size.width / 4),
                startAngle: CGFloat(Double.pi),
                endAngle: 0,
                clockwise: true)
        addCurve(to: CGPoint(x: originalRect.size.width / 2, y: scaledRect.origin.y + scaledRect.size.height),
                controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height / 2)),
                controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width / 2), y: scaledRect.origin.y + (scaledRect.size.height * 3 / 4)))
        close()
    }

}