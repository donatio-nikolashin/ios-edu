import SwiftUI
import ASCollectionView

struct FeedView: View {
    
    @ObservedObject var viewModel = PostViewModel()
    @SceneStorage("zoomingGlobal") var zoomingGlobal: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    Stories()
                    VStack(spacing: 20) {
                        ForEach(0...1, id: \.self) { index in
                            PostCell(post: viewModel.posts[index])
                        }
                    }
                }
            }
            .navigationBarItems(leading: logo)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
    }
    
    var logo: some View {
        Button(action: {}) {
            HStack {
                Image("moment_logo_big")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 100)
            }
        }
    }
    
}

struct FeedView_Previews: PreviewProvider {
    
    static var previews: some View {
        FeedView(viewModel: PostViewModel())
    }
    
}

struct Story: View {
    var image: String = "profile"
    var name: String = "Willie Yam"
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(width: 60, height: 60)
                        .cornerRadius(50)
                }
                .frame(width: 70, height: 70)
                Circle()
                    .stroke(LinearGradient(colors: [.red, .purple, .red, .orange, .yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.3)
                    .frame(width: 68, height: 68)
            }
            Text(name)
                .font(.caption)
        }
    }
}

struct Stories: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15.0) {
                ForEach(0...10, id: \.self) { index in
                    Story(image: "sample_1", name: "Sefran")
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 10)
    }
}
