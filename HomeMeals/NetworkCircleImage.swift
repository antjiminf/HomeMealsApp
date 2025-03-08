import SwiftUI
import ACNetwork

struct NetworkCircleImage: View {
    var size: CGFloat = 100
    let urlString: String
    @State private var imageVM = ImageNetworkVM()
    
    var body: some View {
        Group {
            if let uiImage = imageVM.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ProgressView()
                    .onAppear {
                        if let url = URL(string: urlString) {
                            Task {
                                await imageVM.getImage(url: url)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    NetworkCircleImage(size: 300,
                       urlString: "https://cloudfront-us-east-1.images.arcpublishing.com/copesa/UIFIWREQRVHK7KLG4IWHI6IQXY.jpg")
}
