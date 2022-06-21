import SwiftUI

enum Tab {
    
    case home
    case direct
    case profile
    case settings
    
}

class TabController: ObservableObject {
    
    @Published var activeTab = Tab.home

    func open(_ tab: Tab) {
        activeTab = tab
    }
    
}

class TabBarReference: ObservableObject {
    
    var tabBar: UITabBar?
    
    func hide() {
        tabBar?.isHidden = true
    }
    
    func show() {
        tabBar?.isHidden = false
    }
    
}
