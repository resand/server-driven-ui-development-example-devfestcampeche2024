//
//  RegistrationView.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import SwiftUI

struct RegistrationView: View {
    let config: AuthConfig
    @StateObject var viewModel: AppConfigViewModel
    @State private var fieldValues: [String: String] = [:]
    @State private var fieldValidations: [String: Bool] = [:]
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Logo
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
                        case .failure(_):
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // Title & Subtitle
                if let title = config.title {
                    Text(title)
                        .font(.title)
                        .foregroundColor(Color(hex: config.textColor ?? "#000000"))
                }
                
                if let subtitle = config.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: config.textColor ?? "#000000"))
                }
                
                // Dynamic Fields
                ForEach(config.fields.sorted(by: { $0.order < $1.order })) { field in
                    DynamicFieldView(
                        config: field,
                        value: binding(for: field.id),
                        isValid: validationBinding(for: field.id)
                    )
                }
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Terms & Privacy
                if let termsText = config.termsText {
                    Text(termsText)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                if let privacyText = config.privacyText {
                    Text(privacyText)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                }
                
                // Dynamic Buttons
                ForEach(config.buttons.sorted(by: { $0.order < $1.order })) { button in
                    LoadingButton(
                        title: button.title,
                        isLoading: isLoading && button.action == .register,
                        isEnabled: isFormValid || button.action != .register,
                        backgroundColor: Color(hex: button.backgroundColor ?? "#000000")
                    ) {
                        handleButtonAction(button)
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: config.backgroundColor ?? "#FFFFFF"))
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Binding Methods
    private func binding(for id: String) -> Binding<String> {
        .init(
            get: { fieldValues[id] ?? "" },
            set: {
                fieldValues[id] = $0
                validateField(id: id, value: $0)
            }
        )
    }
    
    private func validationBinding(for id: String) -> Binding<Bool> {
        .init(
            get: { fieldValidations[id] ?? true },
            set: { fieldValidations[id] = $0 }
        )
    }
    
    // MARK: - Validation Methods
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
    
    // MARK: - Action Handlers
    private func handleButtonAction(_ button: ButtonConfig) {
        switch button.action {
        case .register:
            if isFormValid {
                handleRegistration()
            }
        case .login:
            dismiss()
        default:
            break
        }
    }
    
    private func handleRegistration() {
        guard !isLoading else { return }
        
        isLoading = true
        showError = false
        
        Task {
            guard let email = fieldValues["email"],
                  let password = fieldValues["password"] else { return }
            
            await viewModel.signUp(email: email, password: password)
            isLoading = false
            
            if viewModel.error == nil {
                dismiss()
            }
        }
    }
}
