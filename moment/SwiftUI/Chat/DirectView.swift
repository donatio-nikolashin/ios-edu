import SwiftUI

struct DirectView: View {
    
    @EnvironmentObject var tabBar: TabBarReference
    
    @StateObject var chatViewModel = ChatViewModel()
    @State private var query: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $query)
                List {
                    ForEach(chatViewModel.getSortedFilteredChats(query: query)) { chat in
                        ZStack {
                            ChatRow(chat: chat)
                            NavigationLink(destination: {
                                ChatView(chat: chat)
                                    .environmentObject(chatViewModel)
                                    .environmentObject(tabBar)
                            }) {
                                EmptyView()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 0)
                            .opacity(0)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Direct")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button(action: {}) {
                Image(systemName: "square.and.pencil")
            })
        }
    }
    
}

struct DirectView_Previews: PreviewProvider {
    
    static var previews: some View {
        DirectView()
            .environmentObject(TabBarReference())
    }
    
}
