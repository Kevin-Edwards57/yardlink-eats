//
//  UUID+Firestore.swift
//  YardLink Eats
//
//  Created by Kevin Edwards on 1/25/26.
//

import Foundation

extension UUID {
    /// Deterministic UUID from any string (same string => same UUID)
    static func fromFirestoreID(_ s: String) -> UUID {
        UUID(uuidString: s) ?? UUID(uuidString: String(s.prefix(36))) ?? UUID()
    }
}
