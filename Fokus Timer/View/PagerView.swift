//
//  PagerView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 29/09/20.
//

import SwiftUI

struct PagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    @GestureState private var translation: CGFloat = 0
    
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            LazyHStack(spacing: 8) {
                content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(currentIndex) * geometry.size.width)
            .offset(x: translation)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating($translation) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let newIndex = (CGFloat(currentIndex) - offset).rounded()
                    currentIndex = min(max(Int(newIndex), 0), pageCount - 1)
                }
            )
            
        }
    }
}
