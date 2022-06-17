import UIKit

class ClosureSleeve {
    let closure: () -> ()
    
    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }
    
    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func setOnClickListener(for controlEvents: UIControl.Event = .primaryActionTriggered, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}

extension UIView {
    func setOnDoubleClickListener(action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        let tap = UITapGestureRecognizer(target: sleeve, action: #selector(ClosureSleeve.invoke))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
    }
}
