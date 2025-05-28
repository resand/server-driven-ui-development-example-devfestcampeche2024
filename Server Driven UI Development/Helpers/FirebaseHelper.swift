//
//  FirebaseHelper.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseHelper {
    static let shared = FirebaseHelper()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Generic Methods

    func fetchDocument<T: Decodable>(_ type: T.Type, from collection: String, document: String) async throws -> T {
        let docRef = db.collection(collection).document(document)
        let snapshot = try await docRef.getDocument()

        guard snapshot.exists else {
            print("❌ Documento no encontrado: \(collection)/\(document)")
            throw FirebaseError.documentNotFound("\(collection)/\(document)")
        }

        do {
            let decodedData = try snapshot.data(as: T.self)
            return decodedData
        } catch {
            print("❌ Error decodificando datos: \(error.localizedDescription)")
            throw FirebaseError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - Specific Fetchers

    func fetchSplashConfig() async throws -> SplashConfig {
        try await fetchDocument(SplashConfig.self, from: "config", document: "splash")
    }

    func fetchOnboardingConfig() async throws -> OnboardingConfig {
        try await fetchDocument(OnboardingConfig.self, from: "config", document: "onboarding")
    }

    func fetchLoginConfig() async throws -> AuthConfig {
        try await fetchDocument(AuthConfig.self, from: "config", document: "login")
    }

    func fetchRegistrationConfig() async throws -> AuthConfig {
        try await fetchDocument(AuthConfig.self, from: "config", document: "registration")
    }

    func fetchHomeConfig() async throws -> HomeConfig {
        try await fetchDocument(HomeConfig.self, from: "config", document: "home")
    }

    // MARK: - Importación de Configuración Inicial

    func importInitialConfiguration() async throws {
        try await importSplashConfig()
        try await importOnboardingConfig()
        try await importLoginConfig()
        try await importRegistrationConfig()
        try await importHomeConfig()
        print("✅ Configuración inicial importada correctamente")
    }

    // MARK: - Configuraciones individuales

    private func importSplashConfig() async throws {
        let splashConfig: [String: Any] = [
            "showImage": true,
            "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2FLogo-Lockup-Editable-Location.png?alt=media&token=6be190f9-3e9d-4be2-a0da-29327ead42b6",
            "text": "Bienvenido al App Oficial del DevFest Campeche 2024",
            "backgroundColor": "#FFFFFF",
            "textColor": "#000000",
            "duration": 2.0
        ]

        try await db.collection("config").document("splash").setData(splashConfig)
    }

    private func importOnboardingConfig() async throws {
        let onboardingConfig: [String: Any] = [
            "pages": [
                [
                    "id": "page1",
                    "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fresumen2019.JPG?alt=media&token=95c2c1e9-3798-4999-9c9f-33f6ed55e220",
                    "title": "DevFest Campeche 2019",
                    "description": "En 2019, inauguramos el capítulo y ese mismo año realizamos nuestro primer DevFest en la ciudad.",
                    "backgroundColor": "#FFFFFF",
                    "textColor": "#000000"
                ],
                [
                    "id": "page2",
                    "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fresumen2022.jpg?alt=media&token=d85050ef-217c-48d5-acf6-706ecd4aae91",
                    "title": "DevFest Campeche 2022",
                    "description": "Regresamos en 2022 con un evento más grande y con muchas charlas. Volvíamos de la pandemia, y muchos ya querían asistir a eventos presenciales. Tuvimos 11 conferencias, 8 tracks y más de 450 asistentes.",
                    "backgroundColor": "#FFFFFF",
                    "textColor": "#000000"
                ],
                [
                    "id": "page3",
                    "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fresumen2022.jpg?alt=media&token=d85050ef-217c-48d5-acf6-706ecd4aae91",
                    "title": "DevFest Campeche 2024",
                    "description": "Hoy es el evento y aún no tengo foto oficial.",
                    "backgroundColor": "#FFFFFF",
                    "textColor": "#000000"
                ]
            ],
            "showSkipButton": true,
            "buttonConfig": [
                "skipButtonTitle": "Saltar",
                "continueButtonTitle": "Siguiente",
                "finishButtonTitle": "Comenzar",
                "buttonColor": "#000000",
                "buttonTextColor": "#FFFFFF"
            ]
        ]

        try await db.collection("config").document("onboarding").setData(onboardingConfig)
    }

    private func importLoginConfig() async throws {
        let loginConfig: [String: Any] = [
            "title": "Iniciar Sesión",
            "subtitle": "Bienvenido de nuevo",
            "logoURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2FDev%20Fest%20Campeche%202022.png?alt=media&token=5b5545a0-9af0-45c4-b18d-a7f7089fdb04",
            "backgroundColor": "#FFFFFF",
            "textColor": "#000000",
            "fields": [
                [
                    "id": "email",
                    "type": "email",
                    "label": "Correo electrónico",
                    "placeholder": "correo@ejemplo.com",
                    "required": true,
                    "validation": "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$",
                    "errorMessage": "Correo inválido",
                    "order": 1,
                    "keyboardType": "email",
                    "autocapitalization": "none"
                ],
                [
                    "id": "password",
                    "type": "password",
                    "label": "Contraseña",
                    "placeholder": "Ingresa tu contraseña",
                    "required": true,
                    "validation": "^.{6,}$",
                    "errorMessage": "Mínimo 6 caracteres",
                    "order": 2,
                    "keyboardType": "default",
                    "autocapitalization": "none"
                ]
            ],
            "buttons": [
                [
                    "id": "login",
                    "type": "primary",
                    "title": "Iniciar Sesión",
                    "style": "filled",
                    "order": 1,
                    "action": "login",
                    "backgroundColor": "#007AFF",
                    "textColor": "#FFFFFF",
                    "icon": nil
                ],
                [
                    "id": "apple",
                    "type": "social",
                    "title": "Continuar con Apple",
                    "style": "outlined",
                    "order": 2,
                    "action": "appleSignIn",
                    "backgroundColor": "#FFFFFF",
                    "textColor": "#000000",
                    "icon": "apple.logo"
                ],
                [
                    "id": "google",
                    "type": "social",
                    "title": "Continuar con Google",
                    "style": "outlined",
                    "order": 3,
                    "action": "googleSignIn",
                    "backgroundColor": "#FFFFFF",
                    "textColor": "#ea4335",
                    "icon": "g.circle.fill"
                ],
                [
                    "id": "register",
                    "type": "link",
                    "title": "¿No tienes cuenta? Regístrate",
                    "style": "plain",
                    "order": 4,
                    "action": "register",
                    "backgroundColor": nil,
                    "textColor": "#007AFF",
                    "icon": nil
                ]
            ],
            "socialButtons": false,
            "socialConfig": [
                "showApple": false,
                "showGoogle": true
            ],
            "dividerText": "o continúa con"
        ]

        try await db.collection("config").document("login").setData(loginConfig)
    }

    private func importRegistrationConfig() async throws {
        let registrationConfig: [String: Any] = [
            "title": "Registro",
            "subtitle": "Crea tu cuenta",
            "logoURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2FDev%20Fest%20Campeche%202022.png?alt=media&token=5b5545a0-9af0-45c4-b18d-a7f7089fdb04",
            "backgroundColor": "#FFFFFF",
            "textColor": "#000000",
            "fields": [
                [
                    "id": "name",
                    "type": "text",
                    "label": "Nombre completo",
                    "placeholder": "Ingresa tu nombre",
                    "required": true,
                    "validation": "^[a-zA-Z\\s]{2,}$",
                    "errorMessage": "Por favor ingresa un nombre válido",
                    "order": 1,
                    "keyboardType": "default",
                    "autocapitalization": "words"
                ],
                [
                    "id": "email",
                    "type": "email",
                    "label": "Correo electrónico",
                    "placeholder": "correo@ejemplo.com",
                    "required": true,
                    "validation": "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$",
                    "errorMessage": "Por favor ingresa un correo válido",
                    "order": 2,
                    "keyboardType": "email",
                    "autocapitalization": "none"
                ],
                [
                    "id": "password",
                    "type": "password",
                    "label": "Contraseña",
                    "placeholder": "Ingresa tu contraseña",
                    "required": true,
                    "validation": "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$",
                    "errorMessage": "La contraseña debe tener al menos 8 caracteres, una letra y un número",
                    "order": 3,
                    "keyboardType": "default",
                    "autocapitalization": "none"
                ]
            ],
            "buttons": [
                [
                    "id": "register",
                    "type": "primary",
                    "title": "Registrarse",
                    "style": "filled",
                    "order": 1,
                    "action": "register",
                    "backgroundColor": "#007AFF",
                    "textColor": "#FFFFFF",
                    "icon": nil
                ]
            ],
            "termsText": "Al registrarte, aceptas nuestros Términos y Condiciones y Política de Privacidad",
            "privacyText": "Lee nuestra política de privacidad"
        ]

        try await db.collection("config").document("registration").setData(registrationConfig)
    }

    private func importHomeConfig() async throws {
        let homeConfig: [String: Any] = [
            "welcomeText": "DevFest Campeche 2024",
            "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2FCopia%20de%20DF24-Form-Header-Editable.png?alt=media&token=6d9f3e32-0015-47e3-8b2c-6b6da0cdbb0a",
            "backgroundColor": "#FFFFFF",
            "textColor": "#000000",
            "tracksConfig": [
                "selectedTrackId": "ai_ml",
                "tracks": [
                    [
                        "id": "ai_ml",
                        "name": "AI/ML",
                        "color": "#4285F4",
                        "talks": [
                            [
                                "id": "nathaly_alarcon_charla",
                                "title": "Construye tus propias aplicaciones con Gemini",
                                "description": "Cómo conectarse a Gemini, prototipar tus propias aplicaciones y crear tus propias apps utilizando el poder de Gemini.",
                                "speakerName": "Nathaly Alarcon Torrico",
                                "speakerRole": "Data Science Engineer Team Lead",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fnataly.png?alt=media&token=9cf18203-f516-4843-bba5-a1a5d7cb5d25",
                                "time": "10:30 - 11:20",
                                "location": "Escenario Principal",
                                "trackId": "ai_ml",
                                "tags": ["AI/ML", "Gemini"]
                            ],
                            [
                                "id": "lesly_zerna_charla",
                                "title": "Construyendo Proyectos con IA: Desde Redes Neuronales hasta Generative AI con Responsabilidad",
                                "description": "En esta charla, exploraremos el emocionante mundo de la inteligencia artificial, desde los fundamentos de las redes neuronales hasta las fronteras de la Generative AI (usando Gemini, Gemma y la Multimodalidad).",
                                "speakerName": "Lesly Zerna",
                                "speakerRole": "Curriculum Developer at DeepLearning.AI",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Flesly.png?alt=media&token=25e47765-aed7-4bd1-8b34-1432fec1e2f5",
                                "time": "13:30 - 14:20",
                                "location": "Escenario Principal",
                                "trackId": "ai_ml",
                                "tags": ["AI/ML", "ML Focus Area - Responsible ML/AI"]
                            ]
                        ]
                    ],
                    [
                        "id": "web",
                        "name": "Web",
                        "color": "#34A853",
                        "talks": [
                            [
                                "id": "damian_sire_charla",
                                "title": "Angular Signals: Una introducción profunda en las nuevas características + Angular con IA",
                                "description": "Más allá de la existencia de 12.938.123 frameworks de frontend hoy en día y que salga uno nuevo cada semana, veremos cómo las señales pueden ayudarnos a crear aplicaciones más rápidas y eficientes.",
                                "speakerName": "Damián Sire",
                                "speakerRole": "Head of Maintenance at Ingenious Agency",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fdamian.png?alt=media&token=704ff6b8-b087-45ea-9ea6-0ffb53bc4371",
                                "time": "15:30 - 16:20",
                                "location": "Escenario Principal",
                                "trackId": "web",
                                "tags": ["Angular", "Web Technologies", "Gemini"]
                            ],
                            [
                                "id": "luis_aviles_charla",
                                "title": "Aplicaciones web impulsadas por IA: Una integración de modelos Gemini y APIs de Chrome",
                                "description": "Exploraremos una forma práctica de usar TypeScript, Angular y NestJS para crear una aplicación web full-stack desde cero.",
                                "speakerName": "Luis Aviles",
                                "speakerRole": "Technical Lead",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Fluis.png?alt=media&token=f5a43d51-2ac8-43a8-8e58-5159f4cb309d",
                                "time": "18:30 - 19:20",
                                "location": "Escenario Principal",
                                "trackId": "web",
                                "tags": ["Angular", "AI/ML", "Gemini", "Chrome", "Web Technologies"]
                            ]
                        ]
                    ],
                    [
                        "id": "mobile",
                        "name": "Mobile",
                        "color": "#FBBC04",
                        "talks": [
                            [
                                "id": "rene_sandoval_charla",
                                "title": "Server-Driven UI: Actualiza tu App sin Nuevas Publicaciones",
                                "description": "Descubre cómo el enfoque Server-Driven UI te permite actualizar y personalizar tu aplicación móvil en tiempo real sin necesidad de lanzar nuevas versiones.",
                                "speakerName": "René Sandoval",
                                "speakerRole": "Senior iOS Engineer",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Frene.png?alt=media&token=7208b1e7-139a-4bc5-b298-ff49bbce8052",
                                "time": "18:00 - 18:45",
                                "location": "Escenario Principal",
                                "trackId": "mobile",
                                "tags": ["Mobile", "iOS", "Server-Driven UI"]
                            ]
                        ]
                    ],
                    [
                        "id": "soft_skills",
                        "name": "Soft Skills",
                        "color": "#EA4335",
                        "talks": [
                            [
                                "id": "don_chambitas_charla",
                                "title": "¿Cómo comienzo mi currículum?",
                                "description": "Descripción y ejemplos de las principales secciones que un currículum asertivo debería contener.",
                                "speakerName": "Hugo Hernández",
                                "speakerRole": "CEO at Don Chambitas",
                                "imageURL": "https://firebasestorage.googleapis.com/v0/b/dev-fest-campeche-2024.appspot.com/o/demo-server-driven-ui%2Frene.png?alt=media&token=7208b1e7-139a-4bc5-b298-ff49bbce8052",
                                "time": "11:30 - 12:20",
                                "location": "Escenario Principal",
                                "trackId": "soft_skills",
                                "tags": ["Soft Skills", "Career Development"]
                            ]
                        ]
                    ]
                ]
            ]
        ]

        try await db.collection("config").document("home").setData(homeConfig)
    }

    // MARK: - Auth Methods

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func isUserAuthenticated() -> Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Utilidades

    func checkInitialConfiguration() async throws -> Bool {
        let docRef = db.collection("config").document("splash")
        let snapshot = try await docRef.getDocument()
        return snapshot.exists
    }

    func clearConfiguration() async throws {
        let snapshot = try await db.collection("config").getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        print("🗑️ Configuración eliminada correctamente")
    }

    func updateConfig(for screen: String, with data: [String: Any]) async throws {
        try await db.collection("config").document(screen).setData(data, merge: true)
        print("🔄 Configuración de \(screen) actualizada")
    }
}

// MARK: - Extensión para uso fácil

extension FirebaseHelper {
    enum ConfigurationError: Error {
        case configurationAlreadyExists
        case configurationNotFound
        case importError(String)
    }

    func initializeIfNeeded() async throws {
        let configExists = try await checkInitialConfiguration()
        guard !configExists else {
            throw ConfigurationError.configurationAlreadyExists
        }
        try await importInitialConfiguration()
    }

    func resetToDefaults() async throws {
        try await clearConfiguration()
        try await importInitialConfiguration()
    }
}

// MARK: - Error Handling

enum FirebaseError: LocalizedError {
    case decodingError(String)
    case encodingError
    case networkError
    case authError
    case documentNotFound(String)
    case unknownError(Error?)
    case configurationError(String)

    var errorDescription: String? {
        switch self {
        case .decodingError(let message):
            return "Error decodificando datos: \(message)"
        case .encodingError:
            return "Error codificando datos"
        case .networkError:
            return "Error de conexión"
        case .authError:
            return "Error de autenticación"
        case .documentNotFound(let path):
            return "Documento no encontrado: \(path)"
        case .configurationError(let message):
            return "Error de configuración: \(message)"
        case .unknownError(let error):
            return error?.localizedDescription ?? "Error desconocido"
        }
    }
}
