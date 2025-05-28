//
//  LoginView.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 25/10/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    let config: AuthConfig
    @StateObject var viewModel: AppConfigViewModel
    @State private var fieldValues: [String: String] = [:]
    @State private var fieldValidations: [String: Bool] = [:]
    @State private var showRegistration = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LoginHeaderView(config: config)
                LoginFormView(
                    config: config,
                    fieldValues: $fieldValues,
                    fieldValidations: $fieldValidations,
                    isLoading: $isLoading,
                    showError: $showError,
                    errorMessage: errorMessage,
                    onValidation: validateField,
                    onSubmit: handleLogin
                )
                
                if config.socialButtons == true {
                    LoginSocialButtonsView(
                        config: config,
                        isLoading: $isLoading,
                        onSocialLogin: handleButtonAction
                    )
                }
                
                LoginFooterView(
                    config: config,
                    showRegistration: $showRegistration,
                    onButtonAction: handleButtonAction
                )
            }
            .padding()
        }
        .background(Color(hex: config.backgroundColor ?? "#FFFFFF"))
        .sheet(isPresented: $showRegistration) {
            if let registrationConfig = viewModel.registrationConfig {
                RegistrationView(config: registrationConfig, viewModel: viewModel)
            }
        }
        .onReceive(viewModel.$error.compactMap { $0 }) { error in
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Action Handlers
    private func handleButtonAction(_ button: ButtonConfig) {
        switch button.action {
        case .login:
            if isFormValid {
                handleLogin()
            }
        case .register:
            showRegistration = true
        case .googleSignIn:
            handleGoogleSignIn()
        case .appleSignIn:
            handleAppleSignIn()
        default:
            break
        }
    }
    
    private var isFormValid: Bool {
        let requiredFields = config.fields.filter { $0.required }
        let allFieldsFilled = requiredFields.allSatisfy { field in
            let value = fieldValues[field.id] ?? ""
            return !value.isEmpty
        }
        let allFieldsValid = requiredFields.allSatisfy { field in
            fieldValidations[field.id] ?? false
        }
        return allFieldsFilled && allFieldsValid
    }
    
    private func handleLogin() {
        guard !isLoading else { return }
        isLoading = true
        showError = false
        
        Task {
            guard let email = fieldValues["email"],
                  let password = fieldValues["password"] else { return }
            await viewModel.signIn(email: email, password: password)
            isLoading = false
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            isLoading = true
//            await viewModel.signInWithGoogle()
            isLoading = false
        }
    }
    
    private func handleAppleSignIn() {
        Task {
            isLoading = true
//            await viewModel.signInWithApple()
            isLoading = false
        }
    }
    
    private func validateField(id: String, value: String) {
        guard let field = config.fields.first(where: { $0.id == id }) else { return }
        
        if field.required && value.isEmpty {
            fieldValidations[id] = false
            return
        }
        
        if let validation = field.validation {
            do {
                let regex = try NSRegularExpression(pattern: validation)
                let range = NSRange(value.startIndex..., in: value)
                fieldValidations[id] = regex.firstMatch(in: value, range: range) != nil
            } catch {
                fieldValidations[id] = false
            }
        } else {
            fieldValidations[id] = true
        }
        
        showError = false
    }
}

// MARK: - Subviews
struct LoginHeaderView: View {
    let config: AuthConfig
    
    var body: some View {
        VStack(spacing: 20) {
            if let logoURL = config.logoURL {
                AsyncImage(url: URL(string: logoURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.bottom, 20)
            }
            
            if let title = config.title {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: config.textColor ?? "#000000"))
            }
            
            if let subtitle = config.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color(hex: config.textColor ?? "#000000"))
            }
        }
    }
}

struct LoginFormView: View {
    let config: AuthConfig
    @Binding var fieldValues: [String: String]
    @Binding var fieldValidations: [String: Bool]
    @Binding var isLoading: Bool
    @Binding var showError: Bool
    let errorMessage: String
    let onValidation: (String, String) -> Void
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(config.fields.sorted(by: { $0.order < $1.order })) { field in
                DynamicFieldView(
                    config: field,
                    value: bindingForField(field.id),
                    isValid: bindingForValidation(field.id)
                )
            }
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            ForEach(config.buttons.filter { $0.action == .login }) { button in
                LoadingButton(
                    title: button.title,
                    isLoading: isLoading,
                    isEnabled: true,
                    backgroundColor: Color(hex: button.backgroundColor ?? "#000000")
                ) {
                    onSubmit()
                }
            }
        }
    }
    
    private func bindingForField(_ id: String) -> Binding<String> {
        Binding(
            get: { fieldValues[id] ?? "" },
            set: { newValue in
                fieldValues[id] = newValue
                onValidation(id, newValue)
            }
        )
    }
    
    private func bindingForValidation(_ id: String) -> Binding<Bool> {
        Binding(
            get: { fieldValidations[id] ?? true },
            set: { fieldValidations[id] = $0 }
        )
    }
}

struct LoginSocialButtonsView: View {
    let config: AuthConfig
    @Binding var isLoading: Bool
    let onSocialLogin: (ButtonConfig) -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            if let dividerText = config.dividerText {
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text(dividerText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
            }
            
            ForEach(config.buttons.filter { $0.isSocialButton }) { button in
                Button {
                    onSocialLogin(button)
                } label: {
                    HStack {
                        if let icon = button.icon {
                            Image(systemName: icon)
                                .font(.title3)
                        }
                        Text(button.title)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: button.backgroundColor ?? "#FFFFFF"))
                    .foregroundColor(Color(hex: button.textColor ?? "#000000"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .disabled(isLoading)
            }
        }
        .padding(.vertical)
    }
}

struct LoginFooterView: View {
    let config: AuthConfig
    @Binding var showRegistration: Bool
    let onButtonAction: (ButtonConfig) -> Void
    
    var body: some View {
        ForEach(config.buttons.filter { $0.action == .register }) { button in
            Button {
                onButtonAction(button)
            } label: {
                Text(button.title)
                    .foregroundColor(Color(hex: button.textColor ?? "#007AFF"))
            }
        }
    }
}
