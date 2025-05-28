# 📱 Server-Driven UI Development

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-yellow.svg)](https://firebase.google.com/)
[![DevFest](https://img.shields.io/badge/DevFest-Campeche%202024-green.svg)](https://devfestcampeche.com/)

> **Actualiza tu App sin Nuevas Publicaciones**
> 
> Ejemplo práctico de implementación de Server-Driven UI presentado en [DevFestCampeche 2024](https://devfestcampeche.com/).

## 🎯 Descripción

Este proyecto demuestra cómo implementar una arquitectura **Server-Driven UI** que permite:

- ✅ **Actualizar interfaces** en tiempo real sin nuevas versiones de la app
- 🎨 **Personalizar componentes** desde el servidor (colores, textos, validaciones)
- 📊 **A/B Testing** dinámico de interfaces
- 🚀 **Despliegue instantáneo** de nuevas funcionalidades
- 💰 **Reducción de costos** de desarrollo y distribución

## 📋 Características

### 🏗️ Arquitectura
- **SwiftUI** para interfaces nativas
- **Firebase Firestore** como backend de configuración
- **MVVM** con coordinadores de navegación
- **Componentes dinámicos** configurables desde servidor

### 🎭 Pantallas Implementadas
- **Splash Screen** - Configuración dinámica de duración e imágenes
- **Onboarding** - Páginas y flujo personalizable
- **Login/Registro** - Campos y validaciones dinámicas
- **Home** - Contenido completamente servidor-driven

### 🧩 Componentes Dinámicos
- Campos de formulario con validación
- Botones con estilos personalizables
- Imágenes y textos configurables
- Navegación y flujos adaptativos

## 🚀 Configuración Inicial

### 1. Prerrequisitos
- Xcode 15.0+
- iOS 15.0+
- Cuenta de Firebase

### 2. Configuración de Firebase

**⚠️ Importante:** El archivo `GoogleService-Info.plist` fue eliminado por seguridad. Debes configurar tu propio proyecto Firebase:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto
3. Agrega una app iOS con tu Bundle ID
4. Descarga el archivo `GoogleService-Info.plist`
5. Arrastra el archivo a tu proyecto Xcode

### 3. Configuración de Firestore

Crea las siguientes colecciones en Firestore:

#### Colección: `config`

Documentos necesarios:

- `splash` - Configuración de pantalla splash
- `onboarding` - Configuración de onboarding
- `login` - Configuración de pantalla de login
- `registration` - Configuración de registro
- `home` - Configuración de pantalla principal

### 4. Estructura de Datos

#### Ejemplo: Documento `login`
```json
{
  "title": "Iniciar Sesión",
  "subtitle": "Bienvenido de nuevo",
  "logoURL": "https://ejemplo.com/logo.png",
  "backgroundColor": "#FFFFFF",
  "textColor": "#000000",
  "fields": [
    {
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
    }
  ],
  "buttons": [
    {
      "id": "login",
      "type": "primary",
      "title": "Iniciar Sesión",
      "style": "filled",
      "order": 1,
      "action": "login",
      "backgroundColor": "#007AFF",
      "textColor": "#FFFFFF"
    }
  ]
}
```

## 🏛️ Arquitectura del Proyecto

```
Server Driven UI Development/
├── 📱 Modules/
│   ├── SplashView.swift
│   ├── OnboardingView.swift
│   ├── LoginView.swift
│   ├── RegistrationView.swift
│   ├── HomeView.swift
│   └── DynamicViews.swift
├── 📊 Models/
│   └── Models.swift
├── 🎮 ViewModels/
│   └── (ViewModels para cada pantalla)
├── 🧭 Coordinators/
│   └── (Coordinadores de navegación)
├── 🛠️ Helpers/
│   ├── FirebaseHelper.swift
│   └── TransitionsHelpers.swift
└── ➕ Extensions/
    └── (Extensiones de SwiftUI)
```

## 💡 Conceptos Clave

### 1. Modelos Dinámicos
Los modelos implementan `Codable` para deserialización automática desde Firestore:

```swift
struct FieldConfig: Codable, Identifiable {
    let id: String
    let type: FieldType
    let label: String
    let placeholder: String
    let required: Bool
    let validation: String?
    // ...
}
```

### 2. Componentes Reutilizables
Vistas que se adaptan a la configuración del servidor:

```swift
struct DynamicFieldView: View {
    let config: FieldConfig
    @Binding var value: String
    @Binding var isValid: Bool
    // ...
}
```

### 3. Manejo de Estado
Estado centralizado para navegación y datos:

```swift
enum AppState {
    case splash
    case onboarding
    case login
    case registration
    case home
}
```

## 🔧 Uso

### Inicialización Automática
La app importa configuración inicial en el primer arranque:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    FirebaseApp.configure()
    
    Task {
        try await FirebaseHelper.shared.initializeIfNeeded()
    }
    
    return true
}
```

### Actualización Dinámica
Para actualizar la UI sin nueva versión:

1. Modifica la configuración en Firebase Console
2. Los cambios se reflejan instantáneamente en la app
3. No requiere nueva publicación en App Store

## 📚 Recursos Adicionales

- 📖 **Documentación Firebase**: [firebase.google.com/docs](https://firebase.google.com/docs)
- 🎥 **Video de la Charla**: [DevFestCampeche 2024](https://devfestcampeche.com/)
- 📱 **SwiftUI Documentation**: [developer.apple.com/swiftui](https://developer.apple.com/documentation/swiftui)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ve el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**René Sandoval**
- 🆇 X: [@resand](https://twitter.com/resand91)
- 💼 LinkedIn: [René Sandoval](https://linkedin.com/in/resand91)
- 🌐 GitHub: [@resand](https://github.com/resand)

---

## 🎤 Sobre la Charla

**"Server-Driven UI: Actualiza tu App sin Nuevas Publicaciones"**

Presentada en [DevFestCampeche 2024](https://devfestcampeche.com/), esta charla explora cómo el enfoque Server-Driven UI puede agilizar el desarrollo, reducir costos y mejorar la experiencia del usuario, haciendo que las aplicaciones móviles sean más flexibles y adaptables a las necesidades cambiantes del mercado.

### 🎯 Objetivos de Aprendizaje
- Entender los fundamentos de Server-Driven UI
- Implementar componentes dinámicos en SwiftUI
- Configurar Firebase como backend de configuración
- Aplicar patrones de arquitectura escalables
- Desplegar actualizaciones sin intervención del usuario

---

**¡Gracias por explorar este proyecto! 🚀**