//
//  TunerData.swift
//  VariTuner
//
//  Created by Alexander on 10/3/22.
//

import Foundation

struct TunerData {
    var freq: Float = 0
    var amplitude: Float = 0
    var noteName = "–"
    var equave = -1
    var roundedFreq: Float = 0
    var deviationInCents: Float {
        freq.hzToCents(freqToCompare: roundedFreq)
    }
}
