//
//  ErrolChatView.swift
//  YardLink Eats
//
//  The Errol chat UI — floating button + full screen chat
//  Drop this file into your Xcode project alongside ErrolService.swift
//

import SwiftUI
import SwiftData

// MARK: - Errol Floating Button Overlay
// Wrap your ContentView with this in SplashGateView or YardLink_EatsApp

struct ErrolOverlay: View {
    @StateObject private var service = ErrolService()
    @State private var showChat = false
    @State private var pulse = false

    // Pass restaurants from SwiftData into Errol
    let restaurants: [Restaurant]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            // Floating Errol button
            if !showChat {
                Button {
                    showChat = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#009B3A"), Color(hex: "#FFD100")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)

                        // Pulse ring
                        Circle()
                            .stroke(Color(hex: "#009B3A").opacity(0.4), lineWidth: 2)
                            .frame(width: pulse ? 76 : 60, height: pulse ? 76 : 60)
                            .opacity(pulse ? 0 : 0.8)
                            .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: pulse)

                        Text("🇯🇲")
                            .font(.system(size: 26))
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90) // above tab bar
                .onAppear { pulse = true }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showChat) {
            ErrolChatView(service: service, restaurants: restaurants)
        }
        .onChange(of: restaurants) { _, newVal in
            service.restaurants = newVal
        }
        .onAppear {
            service.restaurants = restaurants
        }
        .animation(.spring(response: 0.4), value: showChat)
    }
}

// MARK: - Main Chat View

struct ErrolChatView: View {
    @ObservedObject var service: ErrolService
    let restaurants: [Restaurant]

    @State private var inputText = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @Environment(\.dismiss) private var dismiss

    // Suggested starter prompts
    private let suggestions = [
        "Best oxtail in Brooklyn?",
        "What is ackee & saltfish?",
        "Tell me a Jamaica fact 🇯🇲",
        "Spots open in Queens?"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                errolBanner

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {

                            // Welcome message
                            if service.messages.isEmpty {
                                welcomeCard
                                    .padding(.top, 16)

                                // Suggestion chips
                                suggestionChips
                            }

                            // Chat messages
                            ForEach(service.messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }

                            // Typing indicator
                            if service.isLoading {
                                TypingIndicator()
                                    .id("typing")
                            }

                            // Error
                            if let error = service.errorMessage {
                                ErrorBanner(message: error)
                                    .padding(.horizontal)
                            }

                            Color.clear.frame(height: 8).id("bottom")
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: service.messages.count) { _, _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: service.isLoading) { _, _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                Divider()

                // Input bar
                inputBar
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Subviews

    private var errolBanner: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Errol 🇯🇲")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Your Jamaican food guide")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Button {
                service.clearChat()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [Color(hex: "#009B3A"), Color(hex: "#007A2E")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var welcomeCard: some View {
        VStack(spacing: 10) {
            Text("👋 Wah gwaan!")
                .font(.title2.bold())
            Text("I'm Errol, your guide to the best Jamaican food in NYC. Ask me about restaurants, dishes, or Jamaica itself!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var suggestionChips: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                    Task { await service.send(userText: suggestion) }
                } label: {
                    Text(suggestion)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "#009B3A"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#009B3A").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "#009B3A").opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask Errol anything...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(.separator), lineWidth: 1)
                )

            Button {
                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                inputText = ""
                Task { await service.send(userText: text) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || service.isLoading
                            ? Color(.systemGray3)
                            : Color(hex: "#009B3A")
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || service.isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ErrolMessage
    var isUser: Bool { message.role == "user" }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                Text("🇯🇲")
                    .font(.system(size: 22))
                    .padding(.bottom, 2)
            }

            Text(message.content)
                .font(.body)
                .foregroundStyle(isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isUser
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "#009B3A"), Color(hex: "#007A2E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ))
                        : AnyShapeStyle(Color(.systemBackground))
                )
                .clipShape(
                    .rect(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: isUser ? 18 : 4,
                        bottomTrailingRadius: isUser ? 4 : 18,
                        topTrailingRadius: 18
                    )
                )
                .shadow(color: .black.opacity(isUser ? 0 : 0.06), radius: 4, x: 0, y: 2)

            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text("🇯🇲").font(.system(size: 22))

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 7, height: 7)
                        .offset(y: animate ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(i) * 0.15),
                            value: animate
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer(minLength: 50)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
        }
        .padding(12)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
