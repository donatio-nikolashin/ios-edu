import SwiftUI

struct PinchZoomContext<Context: View>: View {
    
    var context: Context
    var zooming: Binding<Bool>
    
    @inlinable init(zooming: Binding<Bool>, @ViewBuilder context: @escaping () -> Context) {
        self.context = context()
        self.zooming = zooming
    }

    @State var offset: CGPoint = .zero
    @State var scale: CGFloat = 0

    @State var scalePosition: CGPoint = .zero

    @SceneStorage("zoomingGlobal") var zoomingGlobal: Bool = false

    var body: some View {
        ZStack {
            context
                .offset(x: offset.x, y: offset.y)
                .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
                .onChange(of: scale) { newValue in
                    zooming.wrappedValue = scale != 0 && offset != .zero
                    zoomingGlobal = scale != 0 && offset != .zero
                    if scale == -1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            scale = 0
                        }
                    }
                }
            GeometryReader { proxy in
                ZoomGesture(scale: $scale, offset: $offset, scalePosition: $scalePosition)
                    .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
            }
        }
        /*  In iOS 15+ it much more concise to use .overlay for GeometryReader with no .scaleEffect for ZoomGesture
            context
                .overlay {
                    GeometryReader { proxy in
                        ZoomGesture(size: size, scale: $scale, offset: $offset, scalePosition: $scalePosition)
                    }
                }
                .zIndex(scale != 0 ? 1000 : 0)
         */
    }

}

struct ZoomGesture: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var offset: CGPoint

    @Binding var scalePosition: CGPoint

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender:)))
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(sender:)))
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {

        var parent: ZoomGesture

        init(parent: ZoomGesture) {
            self.parent = parent
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
           true
        }

        @objc
        func handlePan(sender: UIPanGestureRecognizer) {
            sender.maximumNumberOfTouches = 2
            if (sender.state == .began || sender.state == .changed) && parent.scale > 0 {
                if let view = sender.view {
                    let translation = sender.translation(in: view)
                    parent.offset = translation
                }
            } else {
                withAnimation {
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            }
        }

        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            if sender.state == .began || sender.state == .changed {
                parent.scale = (sender.scale - 1)
                let scalePoint = CGPoint(
                        x: sender.location(in: sender.view).x / sender.view!.frame.size.width,
                        y: sender.location(in: sender.view).y / sender.view!.frame.size.height
                )
                parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
            } else {
                withAnimation(.easeOut(duration: 0.35)) {
                    parent.scale = -1
                    parent.scalePosition = .zero
                }
            }
        }

    }

}

extension View {

    func zoomable(zooming: Binding<Bool>) -> some View {
        PinchZoomContext(zooming: zooming) {
            self
        }
    }

}
