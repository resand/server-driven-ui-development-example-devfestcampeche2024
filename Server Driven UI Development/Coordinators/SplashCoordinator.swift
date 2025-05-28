//
//  SplashCoordinator.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import SwiftUI
import Combine

class SplashCoordinator: ObservableObject {
    @Published var isLoading = true
    @Published var shouldShowSplash = true
    private var cancellables = Set<AnyCancellable>()
    
    func start(duration: TimeInterval) {
        // Esperar a que la imagen se cargue y luego el tiempo de duración
        Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                withAnimation {
                    self?.shouldShowSplash = false
                }
            }
            .store(in: &cancellables)
    }
}
