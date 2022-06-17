import SwiftUI
import Introspect

struct ChatView: View {
    
    @EnvironmentObject var viewModel: ChatViewModel
    @EnvironmentObject var tabBar: TabBarReference
    
    let chat: Chat
    
    @State private var text = ""
    @State private var focused = false
    @State private var messageIDtoScroll: UUID?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GeometryReader { reader in
                    ScrollView {
                        ScrollViewReader { scrollReader in
                            messages(viewWidth: reader.size.width)
                                .padding(.horizontal)
                                .onChange(of: messageIDtoScroll) { _ in
                                    if let messageID = messageIDtoScroll {
                                        scrollTo(messageID: messageID, shouldAnimate: true, scrollReader: scrollReader)
                                    }
                                }
                                .onAppear {
                                    if let messageID = chat.messages.last?.id {
                                        scrollTo(messageID: messageID, anchor: .bottom, shouldAnimate: false, scrollReader: scrollReader)
                                    }
                                }
                        }
                    }
                }
                toolbar()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.markAsUnread(false, chat: chat)
            }
            /*
                I was not able to solve padding issue under message text field after hiding tab bar
                        .onAppear(perform: self.tabBar.hide)
                        .onDisappear(perform: self.tabBar.show)
            */
        }
    }
    
    let columns = [GridItem(.flexible(minimum: 10))]
    
    func messages(viewWidth: Double) -> some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(chat.messages) { message in
                let received = message.type == .received
                let color: Color = received ? .gray.opacity(0.6) : .blue.opacity(0.7)
                HStack {
                    ZStack {
                        Text(message.text)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(color)
                            .cornerRadius(13)
                    }
                    .frame(width: viewWidth * 0.7, alignment: received ? .leading : .trailing)
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity, alignment: received ? .leading : .trailing)
                .id(message.id)
            }
        }
    }
    
    func toolbar() -> some View {
        ZStack {
            VStack {
                let height: CGFloat = 37
                HStack {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text("Message...")
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .frame(height: height)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                    //                        .focused()
                    Button(action: sendMessage, label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: height, height: height)
                            .background(
                                Circle()
                                    .foregroundColor(text.isEmpty ? .gray : .blue)
                            )
                    })
                    .disabled(text.isEmpty)
                }
                .frame(height: height)
            }
            .padding(.vertical)
            .padding(.horizontal)
        }
        .background(Color.gray.opacity(0.5).edgesIgnoringSafeArea(.bottom))
    }
    
    func sendMessage() {
        if let message = viewModel.sendMessage(text, chat: chat) {
            text = ""
            messageIDtoScroll = message.id
        }
    }
    
    func scrollTo(messageID: UUID, anchor: UnitPoint? = nil, shouldAnimate: Bool, scrollReader: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(shouldAnimate ? Animation.easeIn : nil) {
                scrollReader.scrollTo(messageID, anchor: anchor)
            }
        }
    }
    
}

struct ChatView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChatView(chat: Chat.samples[0])
            .environmentObject(ChatViewModel())
            .environmentObject(TabBarReference())
    }
    
}
