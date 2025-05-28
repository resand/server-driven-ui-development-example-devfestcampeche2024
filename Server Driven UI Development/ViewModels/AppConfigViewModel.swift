//
//  AppConfigViewModel.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import Combine
import Foundation
import Firebase
import FirebaseAuth
import Combine

@MainActor
class AppConfigViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentState: AppState = .splash
    @Published var splashConfig: SplashConfig?
    @Published var onboardingConfig: OnboardingConfig?
    @Published var loginConfig: AuthConfig?
    @Published var registrationConfig: AuthConfig?
    @Published var homeConfig: HomeConfig?
    @Published var isLoading = true
    @Published var error: Error?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding: Bool
    
    // MARK: - Private Properties
    private let firebaseHelper = FirebaseHelper.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.isAuthenticated = Auth.auth().currentUser != nil
        setupAuthStateListener()
    }
    
    // MARK: - Public Methods
    func loadInitialConfigurations() async {
        do {
            isLoading = true
            error = nil
            
            print("🔍 Verificando configuración inicial...")
            let configExists = try await firebaseHelper.checkInitialConfiguration()
            
            if !configExists {
                print("📝 Configuración no encontrada, creando configuración inicial...")
                try await firebaseHelper.importInitialConfiguration()
            }
            
            print("🔄 Cargando configuraciones...")
            
            // Cargamos las configuraciones en paralelo
            async let splashFetch = firebaseHelper.fetchSplashConfig()
            async let onboardingFetch = firebaseHelper.fetchOnboardingConfig()
            async let loginFetch = firebaseHelper.fetchLoginConfig()
            async let registrationFetch = firebaseHelper.fetchRegistrationConfig()
            async let homeFetch = firebaseHelper.fetchHomeConfig()
            
            let (splash, onboarding, login, registration, home) = try await (
                splashFetch,
                onboardingFetch,
                loginFetch,
                registrationFetch,
                homeFetch
            )
            
            // Actualizamos el estado
            self.splashConfig = splash
            self.onboardingConfig = onboarding
            self.loginConfig = login
            self.registrationConfig = registration
            self.homeConfig = home
            
            // Determinar estado inicial
            determineInitialState()
            
            print("✅ Configuraciones cargadas exitosamente")
            
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async {
        do {
            try await firebaseHelper.signIn(email: email, password: password)
            isAuthenticated = true
            currentState = .home
        } catch {
            self.error = error
        }
    }
    
    func signUp(email: String, password: String) async {
        do {
            try await firebaseHelper.signUp(email: email, password: password)
            isAuthenticated = true
            currentState = .home
        } catch {
            self.error = error
        }
    }
    
    func signOut() {
        do {
            try firebaseHelper.signOut()
            isAuthenticated = false
            currentState = .login
        } catch {
            self.error = error
        }
    }
    
    // MARK: - Onboarding Methods
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        currentState = .login
    }
    
    // MARK: - Private Methods
    private func setupAuthStateListener() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.isAuthenticated = user != nil
                self?.updateStateBasedOnAuth()
            }
        }
    }
    
    private func determineInitialState() {
        if currentState == .splash {
            let duration = splashConfig?.duration ?? 2.0
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                updateStateBasedOnAuth()
            }
        } else {
            updateStateBasedOnAuth()
        }
    }
    
    private func updateStateBasedOnAuth() {
        if isAuthenticated {
            currentState = .home
        } else if !hasCompletedOnboarding {
            currentState = .onboarding
        } else {
            currentState = .login
        }
    }
    
    // MARK: - Validation Methods
    func validateField(_ value: String, config: FieldConfig) -> ValidationResult {
        guard config.required || !value.isEmpty else {
            return ValidationResult(isValid: true, message: nil)
        }
        
        guard let validation = config.validation else {
            return ValidationResult(isValid: true, message: nil)
        }
        
        do {
            let regex = try NSRegularExpression(pattern: validation)
            let range = NSRange(value.startIndex..., in: value)
            let isValid = regex.firstMatch(in: value, range: range) != nil
            return ValidationResult(
                isValid: isValid,
                message: isValid ? nil : config.errorMessage
            )
        } catch {
            return ValidationResult(isValid: true, message: nil)
        }
    }
    
    // MARK: - Helper Methods
    func getKeyboardType(for field: FieldConfig) -> UIKeyboardType {
        switch field.keyboardType {
        case .email:
            return .emailAddress
        case .numeric:
            return .numberPad
        case .phone:
            return .phonePad
        case .url:
            return .URL
        default:
            return .default
        }
    }
    
    func getTextContentType(for field: FieldConfig) -> UITextContentType? {
        switch field.type {
        case .email:
            return .emailAddress
        case .password:
            return .password
        case .username:
            return .username
        case .phone:
            return .telephoneNumber
        default:
            return nil
        }
    }
    
    func getAutocapitalization(for field: FieldConfig) -> UITextAutocapitalizationType {
        switch field.autocapitalization {
        case .none?:
            return .none
        case .words:
            return .words
        case .sentences:
            return .sentences
        case .characters:
            return .allCharacters
        default:
            return .none
        }
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        self.error = error
        print("Error en AppConfigViewModel: \(error.localizedDescription)")
    }
}

// MARK: - Preview Helper
#if DEBUG
extension AppConfigViewModel {
    static var preview: AppConfigViewModel {
        let viewModel = AppConfigViewModel()
        viewModel.splashConfig = SplashConfig(
            showImage: true,
            imageURL: "https://example.com/splash.png",
            text: "Bienvenido",
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            duration: 2.0
        )
        return viewModel
    }
}
#endif
