//
//  DynamicViews.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let textColor: Color
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Dynamic Field View
struct DynamicFieldView: View {
    let config: FieldConfig
    @Binding var value: String
    @Binding var isValid: Bool
    @State private var isFocused: Bool = false
    @State private var showError: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label
            if !config.label.isEmpty {
                Text(config.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Input Field
            Group {
                if config.type == .password {
                    SecureField(config.placeholder, text: $value)
                } else {
                    TextField(config.placeholder, text: $value)
                        .keyboardType(getKeyboardType())
                        .textContentType(getTextContentType())
                        .autocapitalization(getAutocapitalizationType())
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(getBorderColor(), lineWidth: 1)
            )
            .onChange(of: value) { _, newValue in
                validateField(newValue)
            }
            .onChange(of: isFocused) { _, focused in
                if !focused {
                    showError = !isValid && !value.isEmpty
                }
            }
            
            // Error Message
            if showError && config.required && !value.isEmpty {
                Text(config.errorMessage ?? "Campo inválido")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
                    .animation(.easeInOut, value: showError)
            }
        }
    }
    
    // MARK: - Private Methods
    private func validateField(_ value: String) {
        if value.isEmpty {
            isValid = !config.required
            showError = false
            return
        }
        
        if let validation = config.validation {
            do {
                let regex = try NSRegularExpression(pattern: validation)
                let range = NSRange(value.startIndex..., in: value)
                isValid = regex.firstMatch(in: value, range: range) != nil
                showError = !isValid
            } catch {
                isValid = false
                showError = true
            }
        } else {
            isValid = true
            showError = false
        }
    }
    
    private func getBorderColor() -> Color {
        if isFocused {
            return .blue
        }
        if showError {
            return .red
        }
        return .gray.opacity(0.3)
    }
    
    private func getKeyboardType() -> UIKeyboardType {
        switch config.keyboardType {
        case .email: return .emailAddress
        case .numeric: return .numberPad
        case .phone: return .phonePad
        case .url: return .URL
        default: return .default
        }
    }
    
    private func getTextContentType() -> UITextContentType? {
        switch config.type {
        case .email: return .emailAddress
        case .password: return .password
        case .username: return .username
        case .phone: return .telephoneNumber
        default: return nil
        }
    }
    
    private func getAutocapitalizationType() -> UITextAutocapitalizationType {
        switch config.autocapitalization {
        case .none?: return .none
        case .words: return .words
        case .sentences: return .sentences
        case .characters: return .allCharacters
        default: return .none
        }
    }
}

// MARK: - Form Validation Helper
struct FormValidator {
    static func isFormValid(fields: [FieldConfig], values: [String: String], validations: [String: Bool]) -> Bool {
        let requiredFields = fields.filter { $0.required }
        
        // Verificar que todos los campos requeridos tengan valor
        let allFieldsFilled = requiredFields.allSatisfy { field in
            let value = values[field.id] ?? ""
            return !value.isEmpty
        }
        
        // Verificar que todos los campos sean válidos
        let allFieldsValid = requiredFields.allSatisfy { field in
            validations[field.id] ?? false
        }
        
        return allFieldsFilled && allFieldsValid
    }
}

// MARK: - Loading Button
struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                action()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle(
            backgroundColor: backgroundColor,
            textColor: .white,
            isEnabled: isEnabled && !isLoading
        ))
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct DynamicViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Campo de email
            DynamicFieldView(
                config: FieldConfig(
                    id: "email",
                    type: .email,
                    label: "Correo electrónico",
                    placeholder: "correo@ejemplo.com",
                    required: true,
                    validation: "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$",
                    errorMessage: "Ingresa un correo válido",
                    order: 1,
                    keyboardType: .email,
                    autocapitalization: FieldConfig.AutocapitalizationType.none
                ),
                value: .constant(""),
                isValid: .constant(true)
            )
            
            // Botón de ejemplo
            LoadingButton(
                title: "Iniciar Sesión",
                isLoading: false,
                isEnabled: true,
                backgroundColor: .blue,
                action: {}
            )
        }
        .padding()
    }
}
#endif
