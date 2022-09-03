//
//  Scale.swift
//  ScalaEditor
//
//  Created by Alexander on 9/3/22.
//

import Foundation

struct Scale: Identifiable, Hashable {
    struct Note: Hashable, Comparable, Identifiable {
        static func < (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
            lhs.cents < rhs.cents
        }
        
        var name: String
        var cents: Double
        let id = UUID()
        init(name: String = "", cents: Double) {
            self.name = name
            self.cents = cents
        }
        
        init(name: String = "", ratio: Ratio) throws {
            self.name = name
            self.cents = try ratio.convertToCents()
        }
        struct Ratio {
            var numerator: Int
            var denominator: Int
            func convertToCents() throws -> Double {
                if denominator == 0 {
                    throw RatioError.zeroDenominator
                }
                let cents = Double(numerator) / Double(denominator)
                if cents < 0 {
                    throw RatioError.negativeRatio
                }
                return cents
            }
        }
    }
    
    let id = UUID()
    var name: String
    var description: String
    var notes: [Note]
    
    // MARK: - Intent(s)
    
    mutating func addPlaceholderNote() {
        notes.insert(Note(name: "", cents: 0), at: notes.endIndex)
    }
}
