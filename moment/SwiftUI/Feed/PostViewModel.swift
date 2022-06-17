import Foundation

class PostViewModel: ObservableObject {
    
    @Published var posts = [Post]()
    
    init() {
        let post1 = Post(id: 0, username: "sefran", caption: "Zenitsu", imageName: "sample_1", location: "Moscow")
        let post2 = Post(id: 1, username: "sefran", caption: "Hinata", imageName: "sample_2", location: "Miami")
        posts.append(post1)
        posts.append(post2)
    }
    
}
