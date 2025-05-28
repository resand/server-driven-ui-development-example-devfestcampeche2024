//
//  TransitionsHelpers.swift
//  Server Driven UI Development
//
//  Created by René Sandoval on 13/11/24.
//

import SwiftUI

struct SlideTransition: ViewModifier {
    let offset: CGFloat
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .animation(animation, value: offset)
    }
}

struct FadeTransition: ViewModifier {
    let opacity: Double
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .animation(animation, value: opacity)
    }
}

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
