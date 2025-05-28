//
//  Models.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import Foundation

// MARK: - App State
enum AppState {
    case splash
    case onboarding
    case login
    case registration
    case home
}

// MARK: - Splash Models
struct SplashConfig: Codable {
    let showImage: Bool
    let imageURL: String?
    let text: String?
    let backgroundColor: String
    let textColor: String?
    let duration: Double?
}

// MARK: - Onboarding Models
struct OnboardingConfig: Codable {
    let pages: [OnboardingPage]
    let showSkipButton: Bool
    let buttonConfig: OnboardingButtonConfig
}

struct OnboardingPage: Codable, Identifiable {
    let id: String
    let imageURL: String
    let title: String
    let description: String
    let backgroundColor: String?
    let textColor: String?
}

struct OnboardingButtonConfig: Codable {
    let skipButtonTitle: String
    let continueButtonTitle: String
    let finishButtonTitle: String
    let buttonColor: String?
    let buttonTextColor: String?
}

// MARK: - Field Configuration
struct FieldConfig: Codable, Identifiable {
    let id: String
    let type: FieldType
    let label: String
    let placeholder: String
    let required: Bool
    let validation: String?
    let errorMessage: String?
    let order: Int
    let keyboardType: KeyboardType?
    let autocapitalization: AutocapitalizationType?
    
    enum FieldType: String, Codable {
        case text
        case email
        case password
        case phone
        case number
        case username
    }
    
    enum KeyboardType: String, Codable {
        case `default`
        case email
        case numeric
        case phone
        case url
    }
    
    enum AutocapitalizationType: String, Codable {
        case none
        case words
        case sentences
        case characters
    }
}

// MARK: - Button Configuration
struct ButtonConfig: Codable, Identifiable {
    let id: String
    let type: ButtonType
    let title: String
    let style: CustomButtonStyle
    let order: Int
    let action: ButtonAction
    let backgroundColor: String?
    let textColor: String?
    let icon: String?
    
    var isSocialButton: Bool {
        return type == .social
    }
    
    enum ButtonType: String, Codable {
        case primary
        case secondary
        case social
        case link
    }
    
    enum CustomButtonStyle: String, Codable {
        case filled
        case outlined
        case plain
    }
    
    enum ButtonAction: String, Codable {
        case login
        case register
        case googleSignIn
        case appleSignIn
        case forgotPassword
        case skip
        case `continue`
        case finish
    }
}

// MARK: - Login/Registration Configuration
struct AuthConfig: Codable {
    let title: String?
    let subtitle: String?
    let logoURL: String?
    let backgroundColor: String?
    let textColor: String?
    let socialButtons: Bool?
    let socialConfig: SocialConfig?
    let fields: [FieldConfig]
    let buttons: [ButtonConfig]
    let termsText: String?
    let privacyText: String?
    let dividerText: String?
}

struct SocialConfig: Codable {
    let showApple: Bool
    let showGoogle: Bool
}

// MARK: - Home Configuration
// En los modelos existentes
struct HomeConfig: Codable {
    let welcomeText: String
    let imageURL: String?
    let backgroundColor: String?
    let textColor: String?
    let webLink: WebLink?
    let tracksConfig: TracksConfig
}

struct TracksConfig: Codable {
    let tracks: [Track]
    let selectedTrackId: String?
}

struct Track: Codable, Identifiable {
    let id: String
    let name: String
    let color: String?
    let talks: [Talk]
}

struct Talk: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let speakerName: String
    let speakerRole: String?
    let imageURL: String?
    let time: String
    let location: String?
    let trackId: String
    let tags: [String]?
}

struct WebLink: Codable {
    let url: String
    let text: String
}

struct HomeSection: Codable, Identifiable {
    let id: String
    let type: SectionType
    let title: String
    let items: [HomeSectionItem]?
    
    enum SectionType: String, Codable {
        case carousel
        case grid
        case list
    }
}

struct HomeSectionItem: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let imageURL: String?
    let action: ItemAction?
    
    struct ItemAction: Codable {
        let type: ActionType
        let value: String
        
        enum ActionType: String, Codable {
            case url
            case screen
            case function
        }
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let message: String?
}
