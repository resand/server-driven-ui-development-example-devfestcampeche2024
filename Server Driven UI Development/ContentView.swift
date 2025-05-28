//
//  ContentView.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 25/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppConfigViewModel()
    @State private var isLoading = true
    @State private var showTransition = false
    
    var body: some View {
        ZStack {
            Group {
                switch viewModel.currentState {
                case .splash:
                    if let config = viewModel.splashConfig {
                        SplashView(config: config)
                            .transition(.opacity)
                    }
                case .onboarding:
                    if let config = viewModel.onboardingConfig {
                        OnboardingView(config: config, viewModel: viewModel)
                            .transition(.slideAndFade)
                    }
                case .login:
                    if let config = viewModel.loginConfig {
                        LoginView(config: config, viewModel: viewModel)
                            .transition(.slideAndFade)
                    }
                case .home:
                    if let config = viewModel.homeConfig {
                        HomeView(config: config, viewModel: viewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentState)
            
            // Loading Overlay
            if isLoading {
                LoadingView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            await viewModel.loadInitialConfigurations()
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Text("DevFest Campeche 2024")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
