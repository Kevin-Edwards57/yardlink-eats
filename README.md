
YardLink Eats
NYC's premier Jamaican restaurant discovery platform, built for the culture.
YardLink Eats is a native iOS application that enables users to discover, explore, and save Jamaican restaurants across New York City and Long Island. The app combines real-time cloud data, interactive mapping, local persistence, and an AI-powered cultural assistant into a seamless mobile experience.
Currently in active development.
Overview
YardLink Eats was built to solve a real problem — there is no centralized platform for finding authentic Jamaican food across NYC. The app pulls from a live Firestore database of 260+ curated restaurants, renders them on an interactive map, and wraps the experience with Errol, a context-aware AI assistant with deep knowledge of Jamaican food and NYC culture.
Features
Borough-filtered restaurant discovery with real-time Firestore sync
Full-text search across the entire restaurant database
Interactive MapKit integration with live restaurant pins
Persistent favorites system using local SwiftData storage
Errol — an AI cultural assistant powered by the Claude API, deployed via a secure Netlify serverless backend with zero client-side API key exposure

## Screenshots

![Restaurant List](screenshots/Yardlkink%20Eats%20%231.webp)
![Map View](screenshots/Yardlkink%20Eats%20%232.webp)
![Errol Chat](screenshots/Yardlkink%20Eats%20%233.webp)
![Favorites](screenshots/Yardlkink%20Eats%20%234.webp)

Tech Stack
LayerTechnologyLanguageSwift 5.9UI FrameworkSwiftUILocal PersistenceSwiftDataCloud DatabaseFirebase FirestoreMapsMapKitAI AssistantClaude API (Anthropic) via Netlify Serverless FunctionsBackendNode.js on Netlify
Architecture
YardLink Eats/
├── ContentView.swift         # Root TabView + Errol floating overlay
├── RootView.swift            # Restaurant list with borough filter + search
├── RestaurantModel.swift     # SwiftData model with Firestore bridge
├── RestaurantMapView.swift   # MapKit restaurant map
├── ErrolChatView.swift       # AI assistant chat UI
├── ErrolService.swift        # Claude API integration via Netlify function
├── FavoritesView.swift       # Saved favorites screen
├── FavoritesStore.swift      # Favorites state management
└── FirestoreService.swift    # Firestore real-time listener
Errol — AI Cultural Assistant
Errol is a context-aware conversational AI assistant embedded directly into the app as a floating overlay. Powered by Anthropic's Claude model, Errol has real-time access to the full restaurant database and is trained on deep knowledge of Jamaican cuisine, culture, and NYC geography. All API communication is routed through a Netlify serverless function, keeping credentials off the client entirely.
Getting Started
Prerequisites — Xcode 15 or higher, iOS 17 or higher, active Firebase project with Firestore enabled, Netlify account with the Errol function deployed.
Setup

Clone the repo
Add your GoogleService-Info.plist to the project
Deploy errol.js to Netlify and set ANTHROPIC_API_KEY as an environment variable
Update the Netlify function URL in ErrolService.swift
Build and run in Xcode

License
Private. All rights reserved.
