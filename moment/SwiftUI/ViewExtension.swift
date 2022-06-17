import SwiftUI
import Introspect

extension View {
    
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder()
                    .opacity(shouldShow ? 1 : 0)
                    .padding(.leading, 1)
                self
            }
        }
    
}
