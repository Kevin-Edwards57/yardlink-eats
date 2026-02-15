//
//  SplashGateView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/22/26.
//


//
//  SplashGateView.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/22/26.
//

import SwiftUI

struct SplashGateView: View {
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                ContentView()
            } else {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    VStack(spacing: 14) {

                        // 🔥 ONLY CHANGE IS HERE
                        Image("SplashIcon")   // ← asset name
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)

                        Text("YardLink Eats")
                            .font(.title.bold())

                        ProgressView()
                            .padding(.top, 10)
                    }
                }
                .task {
                    try? await Task.sleep(nanoseconds: 900_000_000) // ~0.9s
                    withAnimation(.easeInOut) { showMain = true }
                }
            }
        }
    }
}
