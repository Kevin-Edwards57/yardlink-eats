# YardLink Eats

**NYC's premier Jamaican restaurant discovery platform — built for the culture.**

Native iOS app · SwiftUI · Firebase · Claude AI · Currently in active development

---

## Overview

There is no centralized platform for finding authentic Jamaican food across New York City. Google Maps buries it. Yelp does not understand it. YardLink Eats fixes that.

The app pulls from a live Firestore database of 260+ curated Jamaican restaurants across all five boroughs and Long Island, renders them on an interactive map, and wraps the entire experience with Errol — an AI-powered cultural guide who actually knows the difference between a roti shop in Richmond Hill and a jerk spot in the Bronx.

This is not a generic restaurant app with a different color scheme. The data pipeline, the AI context architecture, and the product itself were all built from scratch by one person, for one community.

---

## Features

- Borough-filtered discovery — Browse by Manhattan, Brooklyn, Queens, Bronx, Staten Island, or Long Island with real-time Firestore sync
- Full-text search — Search across the entire restaurant database instantly
- Interactive map — MapKit integration with live restaurant pins across the city
- Favorites — Persistent local favorites system built with SwiftData
- Errol — Context-aware AI cultural guide with deep knowledge of Jamaican cuisine, NYC neighborhoods, and Caribbean culture

---

## Screenshots

| Restaurant List | Map View | Errol Chat | Favorites |
|---|---|---|---|
| ![List](screenshots/Yardlkink%20Eats%20%231.webp) | ![Map](screenshots/Yardlkink%20Eats%20%232.webp) | ![Errol](screenshots/Yardlkink%20Eats%20%233.webp) | ![Favorites](screenshots/Yardlkink%20Eats%20%234.webp) |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Local Persistence | SwiftData |
| Cloud Database | Firebase Firestore |
| Maps | MapKit |
| AI Assistant | Claude API (Anthropic) |
| Serverless Backend | Node.js via Netlify Functions |

---

## System Architecture

```
+----------------------------------------------------------+
|                      iOS App (SwiftUI)                   |
|                                                          |
|   +-----------+    +----------------+    +-----------+   |
|   | RootView  |    | RestaurantMap  |    | Favorites |   |
|   | (Browse / |    |     View       |    |   View    |   |
|   |  Search)  |    |   (MapKit)     |    | (SwiftData|   |
|   +-----+-----+    +-------+--------+    +-----------+   |
|         |                  |                             |
|         +--------+---------+                            |
|                  |                                       |
|        +---------+---------+     +-------------------+  |
|        | FirestoreService  |     |   ErrolChatView   |  |
|        | (Real-time sync)  |     | (Floating overlay)|  |
|        +---------+---------+     +---------+---------+  |
+------------------|--------------------------|-----------+
                   |                          |
                   v                          v
        +--------------------+    +----------------------+
        |  Firebase          |    |  ErrolService.swift  |
        |  Firestore         |    |  (API client)        |
        |  260+ restaurants  |    +----------+-----------+
        |  live database     |               |
        +--------------------+               | HTTPS POST
                                             v
                                  +----------------------+
                                  |  Netlify Serverless  |
                                  |  Function (errol.js) |
                                  |  Node.js runtime     |
                                  +----------+-----------+
                                             |
                                             v
                                  +----------------------+
                                  |  Anthropic Claude    |
                                  |  API                 |
                                  +----------------------+
```

---

## Errol — AI Cultural Guide

Errol is the core engineering differentiator of this project. He is not a wrapper around a generic model with a custom name. The context architecture, the system prompt design, and the depth of knowledge he carries are what make him useful in a way no generic food app can replicate.

### What Errol Can Do

**Restaurant Discovery**

Errol has direct access to the full live Firestore database and answers natural language queries against it in real time:

- "What is the best oxtail spot in Queens?"
- "I want jerk chicken in Brooklyn, what do you recommend?"
- "Find me a Jamaican spot in the Bronx with curry goat"

Every recommendation is grounded in the actual database. If a restaurant is not in the dataset, Errol says so — he does not hallucinate results.

**Jamaican Food and Culture Knowledge**

Errol carries deep knowledge of Jamaican cuisine and Caribbean culture that goes well beyond restaurant listings:

- The history and regional variations of dishes like jerk, ackee and saltfish, escovitch fish, and brown stew chicken
- What to order if you have never had Jamaican food before
- The cultural difference between Jamaican, Trinidadian, and Guyanese cuisine
- Why certain dishes are tied to certain occasions, what "yard food" means, and the significance of Jamaican food in the diaspora

**Proximity and Neighborhood Awareness**

Errol understands NYC geography at the neighborhood level, not just the borough level:

- "I am in Flatbush, what is close to me?" — Errol knows Flatbush is a Caribbean stronghold and filters recommendations accordingly
- "I am near Jamaica Avenue in Queens, what is in the area?" — Errol understands the corridor
- Recommendations are cross-referenced against the live database so every result is a real, approved listing

**NYC Neighborhood Cultural Context**

This is the capability that separates Errol from every other food discovery tool. He does not just know where restaurants are — he understands why certain neighborhoods have the food scenes they do:

- Richmond Hill and South Ozone Park in Queens as the Indo-Caribbean and roti hub
- Flatbush, Crown Heights, and Canarsie in Brooklyn as the core of the Jamaican diaspora in NYC
- The Bronx corridor along White Plains Road and Gun Hill Road
- Why the food in these neighborhoods hits different from anything in a tourist-facing Manhattan spot

A user who just moved to NYC and wants to understand where the culture actually lives gets more from Errol than they would from any map or review platform.

---

### How Errol Works — Engineering Detail

**Context Injection at Request Time**

When a user sends a message, `ErrolService.swift` does not just forward the text to Claude. Before the API call is made, the full restaurant dataset is serialized and injected directly into the system prompt. Errol receives structured data for every restaurant in the database — name, borough, address, phone, website, must-try dishes, and category — on every single request.

This gives Errol real-time access to the live database without any separate retrieval step. No vector search, no RAG pipeline, no latency from an embedding lookup. The dataset is compact enough that full context injection is the most reliable and lowest-latency approach at this scale, and it guarantees Errol is always working from current, approved data.

**Why This Approach**

Most AI-powered apps at this scale bolt a chat interface onto a generic model and call it done. The decision here was to make the data the context — every query Errol answers is grounded in real, curated, human-reviewed restaurant records. That is not something you replicate by prompting a generic model with a borough name.

**Serverless Proxy — Zero Client-Side Key Exposure**

The iOS app never calls the Anthropic API directly. Every request is routed through a Netlify serverless function (`errol.js`) that holds the API key server-side as an environment variable in Netlify's dashboard. This means:

- No API key embedded in the app binary
- No credential exposure in App Store submissions or through reverse engineering
- Request validation and error handling handled at the function layer
- Clean separation between the iOS client and the AI backend

**System Prompt Design**

Errol's system prompt establishes his persona — Queens-aware, culturally fluent, direct — injects the full restaurant JSON, and instructs him to ground every recommendation in the actual data. He does not hallucinate spots. If a restaurant is not in the database, he redirects rather than inventing a result.

**Scaling Path**

The current architecture handles 260+ restaurants with full context injection per request. As the dataset scales, the roadmap includes:

- Pre-filtering context by borough or neighborhood before prompt assembly to reduce token usage
- Semantic search layer using embeddings to retrieve the most relevant restaurant subset before injection
- Firestore vector search integration for proximity-based pre-filtering before the API call

---

## Project Structure

```
YardLink Eats/
+-- ContentView.swift          # Root TabView + Errol floating overlay
+-- RootView.swift             # Restaurant list with borough filter + search
+-- RestaurantModel.swift      # SwiftData model with Firestore bridge
+-- RestaurantMapView.swift    # MapKit restaurant map
+-- ErrolChatView.swift        # AI assistant chat UI
+-- ErrolService.swift         # Claude API integration via Netlify proxy
+-- FavoritesView.swift        # Saved favorites screen
+-- FavoritesStore.swift       # Favorites state management
+-- FirestoreService.swift     # Firestore real-time listener
```

---

## Data Pipeline

The restaurant database is built and maintained through Anansi, a custom Python and Flask scraping and enrichment pipeline developed alongside this app. The full pipeline:

1. `anansi_app.py` — Scrapes and aggregates Jamaican restaurant data across NYC sources via the `/start` endpoint
2. `geocode_restaurants.py` — Enriches records with coordinates via Google Places API
3. `fix_firestore.py` — Cleans and normalizes Firestore documents
4. `migrate_restaurants.py` — Schema-validated migration to the production `restaurants` collection with field allowlist enforcement

All 260+ listings are manually reviewed and approved before appearing in the app. No listing goes live without a human check.

---

## Getting Started

**Prerequisites**
- Xcode 15 or higher
- iOS 17 or higher target
- Active Firebase project with Firestore enabled
- Netlify account for serverless function deployment

**Setup**

```bash
# 1. Clone the repo
git clone https://github.com/Kevin-Edwards57/yardlink-eats.git

# 2. Add your Firebase config
# Drop GoogleService-Info.plist into the YardLink Eats/ directory in Xcode

# 3. Deploy the Netlify function
# Copy errol.js to your Netlify functions folder
# Set ANTHROPIC_API_KEY as an environment variable in the Netlify dashboard

# 4. Update the function URL
# In ErrolService.swift, replace the Netlify function URL with your deployment URL

# 5. Build and run
# Open YardLink Eats.xcodeproj in Xcode and run on simulator or device
```

---

## Roadmap

- Restaurant photos via Google Places API to Firebase Storage pipeline
- App Store submission
- Errol context optimization for larger dataset scale
- User-submitted restaurant additions with admin approval flow
- Neighborhood-level filtering in browse and search views

---

## Built By

YardLink Studio — NYC-based digital agency building websites, mobile apps, and AI tools for small businesses.

yardlinkstudio.com · yardlinkstudio@gmail.com

---

## License

Private. All rights reserved. YardLink Studio 2025
