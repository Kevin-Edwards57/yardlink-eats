//
//  SplashView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/20/26.
//

import SwiftUI

struct SplashView: View {

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        VStack(spacing: 16) {
            Image("SplashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .opacity(opacity)

            Text("YardLink Eats")
                .font(.largeTitle.bold())
                .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
