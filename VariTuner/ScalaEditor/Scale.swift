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
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func < (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
            lhs.cents < rhs.cents
        }
        
        var name: String = ""
        var cents: Double = 0.0
        var numerator = ""
        var denominator = ""
        var showCents = true
        var id = UUID()
    }
    
    var name: String = ""
    var description: String = ""
    var notes: [Note]
    var fundamental: Double = 16.35
    var id = UUID()
    
    init(name: String = "", description: String = "", notes: [Note] = [Note()], fundamental: Double = 16.35, id: UUID = UUID()) {
        self.name = name
        self.description = description
        self.notes = notes
        self.fundamental = fundamental
        self.id = id
    }
    
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
