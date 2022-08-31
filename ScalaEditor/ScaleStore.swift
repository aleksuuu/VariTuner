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

struct Scale {
    
    // TODO: make it so that the array of notes always goes from the lowest to the highest
    struct Note: Hashable {
        var name: String
        var cents: Double
        fileprivate init(name: String = "", cents: Double) {
            self.name = name
            self.cents = cents
        }
        
        var centsString: String { // TODO: use a formatter instead
            get {
                print(self.cents)
                return String(cents)
            }
            set { self.cents = newValue.convertToDouble() }
        }
        
//        var ratioString: (String, String) {
//            get {
//                self.cents.convertToRatio()
//            }
//        }
        
        fileprivate init(name: String = "", cents: String) {
            self.name = name
            self.cents = cents.convertToDouble()
        }
        
        fileprivate init(name: String = "", ratio: Ratio) throws {
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
//    private func ratioToCents(_ ratio: String) -> Double? {
//        if var division = ratio.firstIndex(of: "/") {
//            let numerator = Double(ratio[..<division])
//            if numerator != nil {
//                division = ratio.index(division, offsetBy: 1)
//                let denominator = Double(ratio[division...])
//                if denominator != nil {
//                    return numerator! / denominator!
//                }
//            }
//        }
//        return 0
//    }
    
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
}

class ScaleStore: ObservableObject {
    @Published var scales = [Scale]()
    
    init(named name: String) {
        if scales.isEmpty {
            insertScale(
                named: "12-12_sharps",
                description: "12 out of 12-tET, the most boring tuning (preferring sharps)",
                notes: [
                    Scale.Note(name: "C", cents: 0),
                    Scale.Note(name: "C#", cents: 100),
                    Scale.Note(name: "D", cents: 200),
                    Scale.Note(name: "D#", cents: 300),
                    Scale.Note(name: "E", cents: 400),
                    Scale.Note(name: "F", cents: 500),
                    Scale.Note(name: "F#", cents: 600),
                    Scale.Note(name: "G", cents: 700),
                    Scale.Note(name: "G#", cents: 800),
                    Scale.Note(name: "A", cents: 900),
                    Scale.Note(name: "A#", cents: 1000),
                    Scale.Note(name: "B", cents: 1100),
                    Scale.Note(name: "C", cents: 1200),
                ])
        }
    }
    
    private func insertScale(named name: String, description: String = "", notes: [Scale.Note], at index: Int = 0) {
        let unique = (scales.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let safeIndex = min(max(index, 0), scales.count)
        scales.insert(Scale(name: name, description: description, id: unique, notes: notes), at: safeIndex)
    }
}
