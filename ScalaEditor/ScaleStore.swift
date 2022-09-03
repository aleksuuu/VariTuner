//
//  ScaleStore.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import Foundation

enum RatioError: Error {
    case zeroDenominator
    case negativeRatio
}

struct Scale: Identifiable, Hashable {
    
    // TODO: make it so that the array of notes always goes from the lowest to the highest and add checks for
    struct Note: Hashable, Comparable, Identifiable {
        static func < (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
            lhs.cents < rhs.cents
        }
        
        var name: String
        var cents: Double
        var id: Int
        fileprivate init(name: String = "", cents: Double, id: Int) {
            self.name = name
            self.cents = cents
            self.id = id
        }
        
        fileprivate init(name: String = "", ratio: Ratio, id: Int) throws {
            self.name = name
            self.cents = try ratio.convertToCents()
            self.id = id
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
    
    var name: String
    var description: String
    var id: Int
    var notes: [Note]
    
    fileprivate init(name: String, description: String = "", id: Int, notes: [Note]) {
        self.name = name
        self.description = description
        self.id = id
        self.notes = notes
    }
    
    // MARK: - Intent(s)
    
    mutating func addPlaceholderNote() {
        let unique = (notes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        notes.insert(Note(name: "", cents: 0, id: unique), at: notes.endIndex)
    }
    
//    private mutating func createNote(named name: String, cents: Double) {
//        let unique = (notes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
//        let index = notes.firstIndex(where: { $0.cents > cents }) ?? notes.endIndex
//        notes.insert(Note(name: name, cents: cents, id: unique), at: index)
//    }
}

class ScaleStore: ObservableObject {
    @Published var scales = [Scale]()
    
    init(named name: String) {
        if scales.isEmpty {
            insertScale(
                named: "12-12_sharps",
                description: "12 out of 12-tET, the most boring tuning (preferring sharps)",
                notes: createNotes(nameCentsArray:[
                    ("C", 0),
                    ("C#", 100),
                    ("D", 200),
                    ("D#", 300),
                    ("E", 400),
                    ("F", 500),
                    ("F#", 600),
                    ("G", 700),
                    ("G#", 800),
                    ("A", 900),
                    ("A#", 1000),
                    ("B", 1100),
                    ("C", 1200)
                    ])
                )
        }
    }
    
    private func createNotes(nameCentsArray: [(String, Double)]) -> [Scale.Note] {
        var notesArray: [Scale.Note] = []
        for nameCents in nameCentsArray {
            let unique = (notesArray.max(by: { $0.id < $1.id })?.id ?? 0) + 1
            let index = notesArray.firstIndex(where: { $0.cents > nameCents.1 }) ?? notesArray.endIndex
            notesArray.insert(Scale.Note(name: nameCents.0, cents: nameCents.1, id: unique), at: index)
        }
        return notesArray
    }
    
    
    private func insertScale(named name: String, description: String = "", notes: [Scale.Note], at index: Int = 0) {
        let unique = (scales.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let safeIndex = min(max(index, 0), scales.count)
        scales.insert(Scale(name: name, description: description, id: unique, notes: notes), at: safeIndex)
    }
    
}
