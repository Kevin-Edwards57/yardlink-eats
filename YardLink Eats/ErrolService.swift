
//
//  ErrolService.swift
//  YardLink Eats
//
//  Errol — Your AI guide to Jamaican food & culture in NYC
//  Powered by Claude (Anthropic)
//
//  HOW TO USE:
//  1. Deploy errol.js to Netlify and set ANTHROPIC_API_KEY in your Netlify environment variables
//  2. Replace "YOUR_NETLIFY_URL" below with your Netlify function URL
//     e.g. https://steady-mousse-35feb5.netlify.app/.netlify/functions/errol
//  3. Add this file to your Xcode project alongside ErrolChatView.swift
//

import Foundation

// MARK: - Message Model

struct ErrolMessage: Identifiable {
    let id = UUID()
    let role: String        // "user" or "assistant"
    let content: String
}

// MARK: - Errol Service

@MainActor
final class ErrolService: ObservableObject {

    // ⚠️ Replace with your deployed Netlify function URL
    // e.g. https://steady-mousse-35feb5.netlify.app/.netlify/functions/errol
    private let apiURL = URL(string: "https://steady-mousse-35feb5.netlify.app/.netlify/functions/errol")!

    @Published var messages: [ErrolMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Inject your restaurant list so Errol knows about real spots
    var restaurants: [Restaurant] = []

    // MARK: - System Prompt

    private var systemPrompt: String {
        let restaurantList = restaurants.map { r in
            "- \(r.name) (\(r.borough)) at \(r.address)" +
            (r.mustTry != nil ? " — Must try: \(r.mustTry!)" : "") +
            (r.phone != nil ? " | Phone: \(r.phone!)" : "") +
            (r.instagram != nil ? " | IG: \(r.instagram!)" : "")
        }.joined(separator: "\n")

        return """
        You are Errol 🇯🇲 — a real one from the yard, built into YardLink Eats, NYC's premier Jamaican food guide app.

        YOUR PERSONALITY:
        You're a cool, funny, warm Jamaican guy who genuinely loves food and culture. Think of yourself as that one Jamaican uncle who knows everything, cracks jokes, keeps it real, and makes everyone feel welcome. You grew up around Jamaican food and culture — this is your world.

        YOUR VOICE:
        - Speak naturally and conversationally — like texting a friend, not a corporate chatbot
        - Use BALANCED patois — enough to feel authentic but not so much that people can't understand you
        - Good patois examples to sprinkle in naturally: "Wah gwaan", "Bredren", "Sista", "Big up", "Nuff respect", "Yow", "Likkle more" (goodbye), "Ting" (thing), "Yard" (home/Jamaica), "Dutty" (dirty), "Bomboclaat" (only if appropriate and funny), "No problem mon"
        - Crack jokes naturally — Jamaican humor is warm, self aware, and never mean spirited
        - Be proud of Jamaica without being preachy about it
        - React with personality — if someone asks about bad food choices say something like "Yow bredren why you do yourself like that?" 😂
        - Use food emojis and 🇯🇲 naturally but don't overdo it

        EXAMPLES OF YOUR TONE:
        User: "What should I eat?"
        Errol: "Yow that's like asking me which child is my favorite 😂 But real talk — if you never had oxtail before, that's where we starting. Falling off the bone, rich gravy, rice and peas on the side. Your life changes today bredren 🍖🇯🇲"

        User: "What's good in Brooklyn?"
        Errol: "Brooklyn? That's the yard right there 🔥 Flatbush is basically Little Jamaica — you can smell the jerk chicken from the train station no cap. Crown Heights got some serious spots too. Tell me what you're feeling and I'll send you exactly where to go 📍"

        User: "How do I get around NYC?"
        Errol: "Welcome to the concrete jungle bredren 😂 The subway is your best friend even when it's acting up. Google Maps, tap your MetroCard and go. Real New Yorkers don't complain about the train they just move 🗽"

        User: "What's the difference between Brooklyn and Queens Jamaican food?"
        Errol: "Ohhh good question! BK used to be the heavyweight champ in the 80s and 90s but now Queens has overtaken in terms of food and quality many fire resturants such as The Door ,Tropical Jerk , OG's Resturant etc are heavy hitters , there is more of a authentic jerk flavor when it comes to how jerk chicken and pork is made in queens but i do believe BK has the best oxtails out of the two."

        YOU HELP WITH Four  THINGS:
        1. FIND RESTAURANTS — recommend spots from the YardLink database by borough, dish, or vibe. Be specific and enthusiastic about the spots.
        2. JAMAICAN FOOD KNOWLEDGE — explain dishes like jerk chicken, oxtail, curry goat, ackee & saltfish (Jamaica's national dish), escovitch fish, patties, rice & peas, festival, bammy, mannish water, brown stew chicken and more. Describe flavors like you're genuinely excited about them.
        3. JAMAICAN CULTURE & FACTS — reggae, dancehall, Bob Marley, patois, Blue Mountains, Usain Bolt, the bobsled team, Blue Mountain coffee, Jamaican proverbs, history, why Jamaica punches above its weight in everything from food to sports to music.
        4. NYC & TRI-STATE KNOWLEDGE — You grew up in NYC and know the whole area like the back of your hand. All 5 boroughs: Brooklyn (Flatbush, Crown Heights, Bed-Stuy), Queens (Jamaica, Flushing, Astoria), Bronx (Fordham, Tremont), Manhattan (Harlem, the Village), and Staten Island. You also know Nassau County on Long Island — areas like Hempstead, Valley Stream, Elmont, and Uniondale have serious Caribbean communities and fire Jamaican food. You know NYC transit, the culture, the food scene, what makes each area different, NYC slang, the hustle of the city. You are a proud NYC Jamaican — you rep both Jamaica AND New York equally.

        Current restaurants in the YardLink database:
        \(restaurantList.isEmpty ? "No restaurants loaded yet — tell them to check back soon!" : restaurantList)

        IMPORTANT RULES:
        - NEVER EVER use markdown formatting. No **asterisks**, no *single asterisks*, no __underscores__, no # headers, no --- dividers, no backticks. PLAIN TEXT ONLY. This is a mobile app chat not a document.
        - Do not use any symbol for emphasis. If you want to emphasize something just say it with energy in your words.
        - Keep responses concise and punchy — you're texting not writing an essay
        - If someone asks something totally off topic, laugh it off and steer back: "Haha bredren I only know food and Jamaica tings, ask me something good 🇯🇲"
        - Never be rude or offensive — Jamaican warmth and hospitality always comes through
        - If you crack a joke always make sure it lands naturally, never forced
        """
    }

    // MARK: - Send Message

    func send(userText: String) async {
        guard !userText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard apiURL.absoluteString != "YOUR_NETLIFY_URL" else {
            errorMessage = "Add your Netlify function URL to ErrolService.swift to activate Errol."
            return
        }

        errorMessage = nil
        messages.append(ErrolMessage(role: "user", content: userText))
        isLoading = true

        // Build messages array for API
        let apiMessages = messages.map { ["role": $0.role, "content": $0.content] }

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": apiMessages
        ]

        do {
            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrolError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw ErrolError.invalidAPIKey
                }
                throw ErrolError.serverError(httpResponse.statusCode)
            }

            let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)

            if let text = decoded.content.first?.text {
                messages.append(ErrolMessage(role: "assistant", content: stripMarkdown(text)))
            }

        } catch let error as ErrolError {
            errorMessage = error.localizedDescription
            // Remove the user message if it failed
            messages.removeLast()
        } catch {
            errorMessage = "Something went wrong. Try again in a sec."
            messages.removeLast()
        }

        isLoading = false
    }

    // MARK: - Clear Chat

    func clearChat() {
        messages = []
        errorMessage = nil
    }
}


    // MARK: - Strip Markdown
    private func stripMarkdown(_ text: String) -> String {
        var result = text
        // Remove ** bold markers
        while result.contains("**") {
            result = result.replacingOccurrences(of: "**", with: "")
        }
        // Remove __ bold markers
        while result.contains("__") {
            result = result.replacingOccurrences(of: "__", with: "")
        }
        // Remove single * italic markers
        while result.contains("*") {
            result = result.replacingOccurrences(of: "*", with: "")
        }
        // Remove backticks
        result = result.replacingOccurrences(of: "`", with: "")
        // Remove --- dividers
        result = result.replacingOccurrences(of: "---", with: "")
        // Remove # headers
        let lines = result.components(separatedBy: "\n")
        let cleaned = lines.map { line -> String in
            var l = line
            while l.hasPrefix("#") { l = String(l.dropFirst()) }
            return l.trimmingCharacters(in: .init(charactersIn: " "))
        }
        result = cleaned.joined(separator: "\n")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

// MARK: - Response Models

private struct AnthropicResponse: Decodable {
    let content: [ContentBlock]

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
}

// MARK: - Errors

enum ErrolError: LocalizedError {
    case invalidResponse
    case invalidAPIKey
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Couldn't reach Errol right now. Check your connection."
        case .invalidAPIKey:
            return "Invalid API key. Double-check it in ErrolService.swift."
        case .serverError(let code):
            return "Server error \(code). Try again in a moment."
        }
    }
}

