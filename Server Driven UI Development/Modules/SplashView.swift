//
//  SplashView.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 25/10/24.
//

import SwiftUI
import Combine

struct SplashView: View {
    let config: SplashConfig
    @StateObject private var imageLoader = ImageLoader()
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            Color(hex: config.backgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if config.showImage {
                    if let uiImage = imageLoader.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
                
                if let text = config.text {
                    Text(text)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: config.textColor ?? "#000000"))
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .opacity(isReady ? 1 : 0)
            .animation(.easeIn(duration: 0.5), value: isReady)
        }
        .onAppear {
            loadSplashContent()
        }
    }
    
    private func loadSplashContent() {
        if config.showImage, let imageURL = config.imageURL {
            imageLoader.loadImage(from: imageURL) { success in
                if success {
                    withAnimation {
                        isReady = true
                    }
                }
            }
        } else {
            withAnimation {
                isReady = true
            }
        }
    }
}

// MARK: - Image Loader
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    
    func loadImage(from urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
                completion(image != nil)
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

// MARK: - Preview Provider
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(config: SplashConfig(
            showImage: true,
            imageURL: "https://picsum.photos/200",
            text: "Bienvenido a la App",
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            duration: 2.0
        ))
    }
}
