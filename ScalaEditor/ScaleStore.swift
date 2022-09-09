//
//  ScaleStore.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import Foundation

class ScaleStore: ObservableObject {
    @Published var scales = [Scale]()
    
    init(named name: String) {
        if scales.isEmpty {
            scales.insert(
                Scale(name: "12-12_sharps",
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
                    Scale.Note(name: "C", cents: 1200)
                  ]), at: 0
            )
        }
    }
    
    
}
