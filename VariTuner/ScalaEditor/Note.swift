//
//  Note.swift
//  VariTuner
//
//  Created by Alexander on 10/13/22.
//

import Foundation

extension Note: Comparable, Identifiable {
    static func == (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Scale.Note, rhs: Scale.Note) -> Bool {
        lhs.cents < rhs.cents
    }
}
