//
//  StrokedTextViewModifier.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/23.
//

import SwiftUI

struct StrokedTextModifier: ViewModifier {
    let id = UUID()
    var strokeSize: CGFloat
    var strokeColor: Color

    init(strokeSize: CGFloat, strokeColor: Color) {
        self.strokeSize = strokeSize
        self.strokeColor = strokeColor
    }


    func body(content: Content) -> some View {
        if strokeSize > 0 {
            strokeBackgroundView(content: content)
        } else {
            content
        }
    }


    func strokeBackgroundView(content: Content) -> some View {
        content
            .padding(strokeSize * 2)
            .background(strokeView(content: content))
    }


    func strokeView(content: Content) -> some View {
        Rectangle()
            .foregroundColor(strokeColor)
            .mask(maskView(content: content))
    }


    func maskView(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            context.drawLayer { ctx in
                if let resolvedView = context.resolveSymbol(id: id) {
                    ctx.draw(resolvedView, at: .init(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}


extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokedTextModifier(strokeSize: width, strokeColor: color))
    }
}
