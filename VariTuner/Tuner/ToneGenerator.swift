//
//  ToneGenerator.swift
//  VariTuner
//
//  Created by Alexander on 10/6/22.
//

import Foundation
import AudioKit
import SporthAudioKit

class ToneGenerator: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()

    @Published var currentFreq: Double? {
        didSet {
            if let freq = currentFreq {
                if freq == oldValue {
                    if tone.isStarted {
                        tone.stop()
                    }
                    currentFreq = nil
                } else {
                    tone.parameter1 = AUValue(freq)
                    if !tone.isStarted {
                        tone.start()
                    }
                }
            }
        }
    }

    let tone = OperationGenerator { _ in
        let tone = Operation.sineWave(frequency: Operation.parameters[0], amplitude: 0.5)
        return tone
    }


    init() {
        engine.output = tone
    }
}

