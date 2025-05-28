//
//  OnboardingScreen.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 25/10/24.
//

import SwiftUI

struct OnboardingView: View {
    let config: OnboardingConfig
    @StateObject var viewModel: AppConfigViewModel
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(config.pages) { page in
                OnboardingPageView(page: page)
                    .tag(config.pages.firstIndex(where: { $0.id == page.id }) ?? 0)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .overlay(
            VStack {
                if config.showSkipButton {
                    Button(config.buttonConfig.skipButtonTitle) {
                        viewModel.completeOnboarding()
                    }
                    .foregroundColor(Color(hex: config.buttonConfig.buttonTextColor ?? "#000000"))
                    .padding()
                }
                
                Button(currentPage == config.pages.count - 1 ?
                      config.buttonConfig.finishButtonTitle :
                      config.buttonConfig.continueButtonTitle) {
                    if currentPage == config.pages.count - 1 {
                        viewModel.completeOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(
                    backgroundColor: Color(hex: config.buttonConfig.buttonColor ?? "#000000"),
                    textColor: Color(hex: config.buttonConfig.buttonTextColor ?? "#FFFFFF"),
                    isEnabled: true
                ))
                .padding()
            }
            .padding(.bottom, 50),
            alignment: .bottom
        )
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: page.imageURL)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(page.title)
                .font(.title)
                .bold()
                .foregroundColor(Color(hex: page.textColor ?? "#000000"))
                .multilineTextAlignment(.center)
            
            ScrollView {
                Text(page.description)
                    .font(.body)
                    .foregroundColor(Color(hex: page.textColor ?? "#000000"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxHeight: 150)
        }
        .padding()
        .background(Color(hex: page.backgroundColor ?? "#FFFFFF"))
    }
}
