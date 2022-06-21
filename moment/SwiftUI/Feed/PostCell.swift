import SwiftUI
import ASCollectionView

struct PostCell: View {
    
    let post: Post
    
    @State var liked = false
    @State var zooming = false
    
    var header: some View {
        HStack {
            Image(post.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(post.username).font(.system(size: 14)).bold()
                Text(post.location).font(.system(size: 14))
            }
            Spacer()
            Image(systemName: "ellipsis")
                .padding()
        }
        .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 0))
    }
    
    var buttons: some View {
        HStack {
            Image(systemName: liked ? "heart.fill" : "heart")
                .renderingMode(.template)
                .foregroundColor(liked ? .red : Color(.label))
                .onTapGesture {
                    self.liked.toggle()
                }
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            Image(systemName: "bubble.left")
                .padding(.init(top: 0, leading: 6, bottom: 0, trailing: 0))
            Image(systemName: "paperplane")
                .padding(.init(top: 0, leading: 6, bottom: 0, trailing: 0))
            Spacer()
        }
        .font(.system(size: 22, weight: .light))
        .padding(.init(top: 10, leading: 13, bottom: 10, trailing: 12))
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                Text("\(post.username) ").font(.system(size: 14)).bold() +
                Text(post.caption).font(.system(size: 14))
            }
            .padding([.leading, .trailing])
            Text("41 minutes ago")
                .foregroundColor(Color(.systemGray2))
                .font(.system(size: 14))
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var image: some View {
        Image(post.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .zoomable(zooming: $zooming)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            image
                .zIndex(1)
            buttons
            footer
            Spacer()
        }
        .zIndex(zooming ? 1000 : 0)
    }
}

struct PostCell_Previews: PreviewProvider {
    
    static var previews: some View {
        PostCell(post: Post(id: 0, username: "sefran", caption: "Zenitsu", imageName: "sample_1", location: "Moscow"))
    }
    
}
