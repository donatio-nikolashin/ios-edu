import SwiftUI
import Introspect

struct MainView: View {
    
    @StateObject private var tabController = TabController()
    @EnvironmentObject private var tabBarReference: TabBarReference
    
    var body: some View {
        TabView(selection: $tabController.activeTab) {
            FeedView()
                .tag(Tab.home)
                .tabItem {
                    Text("Feed")
                    Image("tab_bar_home")
                }
            DirectView()
                .environmentObject(tabBarReference)
                .tag(Tab.direct)
                .tabItem {
                    Text("Direct")
                    Image("tab_bar_chat")
                }
            ProfileView()
                .tag(Tab.profile)
                .tabItem {
                    Text("Profile")
                    Image("tab_bar_profile")
                }
            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Text("Settings")
                    Image("tab_bar_settings")
                }
        }
        .introspectTabBarController { UITabBarController in
            self.tabBarReference.tabBar = UITabBarController.tabBar
        }
    }

}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView()
            .environmentObject(TabBarReference())
    }
    
}


struct ProfileView: View {
    
    var body: some View {
        NavigationView {
            Text("Profile")
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
}

struct SettingsView: View {
    
    @EnvironmentObject var store: SessionStore
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Security")) {
                    Button("Log Out") {
                        if store.signOut() {
                            print("Unable to sign out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
}
