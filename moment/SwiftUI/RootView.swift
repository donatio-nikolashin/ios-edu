import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var store: SessionStore
    
    var body: some View {
        Group {
            if (store.session != nil) {
                MainView()
                    .environmentObject(TabBarReference())
            } else {
                LoginView()
            }
        }
        .onAppear(perform: store.listen)
    }

}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        RootView()
            .environmentObject(SessionStore())
    }
    
}
