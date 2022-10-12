//
//  Scale.swift
//  ScalaEditor
//
//  Created by Alexander on 9/3/22.
//

import Foundation
import SwiftUI

enum RatioError: Error {
    case zeroDenominator
    case negativeRatio
    case invalidString
}

struct Scale: Identifiable, Hashable, Codable, Comparable {
    static func < (lhs: Scale, rhs: Scale) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
    
    struct Note: Hashable, Comparable, Identifiable, Codable {
        static func == (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
            lhs.id == rhs.id
        }
        
        static func < (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
            lhs.cents < rhs.cents
        }
        
        var ratioMode = false
        var name: String = ""
        var cents: Double
        var numerator = ""
        var denominator = ""
        var ratio: Ratio? {
            try? Ratio(numerator: numerator, denominator: denominator)
        }
        var id = UUID()
        
        init(name: String = "", cents: Double) {
            self.name = name
            self.cents = cents
        }
        init(name: String = "", ratio: Ratio) throws {
            self.name = name
            self.cents = ratio.cents
            self.numerator = String(ratio.numerator)
            self.denominator = String(ratio.denominator)
            self.ratioMode = true
        }
        
        
        struct Ratio: Hashable, Codable {
            var numerator: Int
            var denominator: Int
            
            init(numerator: Int, denominator: Int) throws {
                if denominator == 0 {
                    throw RatioError.zeroDenominator
                }
                if Double(numerator) / Double(denominator) <= 1 {
                    throw RatioError.negativeRatio
                }
                self.numerator = numerator
                self.denominator = denominator
            }
            
            init(numerator: String, denominator: String) throws {
                if let num = Int(numerator), let denom = Int(denominator) {
                    self = try Ratio(numerator: num, denominator: denom)
                } else {
                    throw RatioError.invalidString
                }
            }
            var cents: Double {
                1200 * log2(Double(numerator) / Double(denominator))
            }
        }
    }
    
    var id = UUID()
    var name: String
    var description: String
    var notes: [Note]
    var fundamental: Double = 16.35
    
    var lowestFrequencies: [Double] {
        var freqs = [fundamental]
        for note in notes[1...] {
            freqs.append(note.cents.centsToHz(lowerFreq: fundamental))
        }
        return freqs
    }
    
    var equaveRatio: Double {
        notes.last?.cents.centsToRatio() ?? 2
    }
    
    // MARK: - Intent(s)
    
    mutating func addPlaceholderNote() {
        notes.insert(Note(name: "", cents: 0), at: notes.endIndex)
    }
}
