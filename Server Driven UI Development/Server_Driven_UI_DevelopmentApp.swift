//
//  Server_Driven_UI_DevelopmentApp.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 25/10/24.
//

import FirebaseCore
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        Task {
            do {
                try await FirebaseHelper.shared.initializeIfNeeded()
            } catch FirebaseHelper.ConfigurationError.configurationAlreadyExists {
                print("✅ La configuración ya existe")
            } catch {
                print("❌ Error al inicializar la configuración: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    @main
    struct Server_Driven_UI_DevelopmentApp: App {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    }
}
