//
//  Scale.swift
//  ScalaEditor
//
//  Created by Alexander on 9/3/22.
//

import Foundation

enum RatioError: Error {
    case zeroDenominator
    case negativeRatio
    case invalidString
}

extension Scale: Identifiable, Comparable {
    static func < (lhs: Scale, rhs: Scale) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
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
    
    var notes: Set<Note> {
        get { (notes_ as? Set<Note>) ?? [] }
        set { notes_ = newValue as NSSet }
    }
    
    // MARK: - Intent(s)
    
    mutating func addPlaceholderNote() {
        notes.insert(Note(name: "", cents: 0), at: notes.endIndex)
    }
}
