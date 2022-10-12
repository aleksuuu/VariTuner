//
//  Tuner.swift
//  VariTuner
//
//  Created by Alexander on 9/11/22.
//  Adapted from AudioKit Cookbook (https://github.com/AudioKit/Cookbook)

import AudioKit
import AudioKitEX
import Foundation
import SoundpipeAudioKit
import SporthAudioKit

// TODO: Ability to produce a pitch. Improve UI.

class TunerConductor: ObservableObject, HasAudioEngine {
    @Published var data = TunerData()
    
    var scale: Scale
    
    let engine = AudioEngine()
    let initialDevice: Device

    let mic: AudioEngine.InputNode
    let tappableNodeA: Fader
    let tappableNodeB: Fader
    let tappableNodeC: Fader
    

    var tracker: PitchTap!

    @Published var currentFreq: Double? {
        didSet {
            if let freq = currentFreq {
                if freq == oldValue {
                    if tone.isStarted {
                        tone.stop()
                    }
                    currentFreq = nil
                } else {
                    switch freq {
                    case _ where freq > TuningConstants.highestFreq:
                        tone.parameter1 = AUValue(TuningConstants.highestFreq)
                    case _ where freq < TuningConstants.lowestFreq:
                        tone.parameter1 = AUValue(TuningConstants.lowestFreq)
                    default:
                        tone.parameter1 = AUValue(freq)
                    }
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


    init(scale: Scale) {
        guard let input = engine.input else { fatalError() }

        guard let device = engine.inputDevice else { fatalError() }

        initialDevice = device

        self.scale = scale
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        engine.output = tone

        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                self.update(pitch[0], amp[0])
            }
        }
    }

    func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        
        guard amp > 0.1 && pitch > Float(scale.fundamental) && pitch > 30 else { return }

        data.pitch = pitch
        data.amplitude = amp

        var frequency = pitch
        
        var equave = 0
        while frequency >= Float(scale.fundamental * scale.equaveRatio) {
            frequency /= Float(scale.equaveRatio)
            equave += 1
        }
        
        // frequency is now in the lowest equave
        
        var minDeviation: Float = 10000
        
        var noteName = "-"
        
        var closestFrequency = Float(scale.fundamental)
        
        for (index, note) in scale.notes.enumerated() {
            let freqToCompare = Float(scale.lowestFrequencies[index])
            let deviation = freqToCompare - frequency
            if abs(deviation) < abs(minDeviation) {
                noteName = note.name.isEmpty ? "\(index)" : note.name
                minDeviation = deviation
                closestFrequency = freqToCompare
            }
        }
        data.noteName = "\(noteName)"
        data.equave = equave
        data.deviation = minDeviation * pow(2, Float(equave))
        data.deviationInCents = frequency.hzToCents(lowerFreq: closestFrequency)
    }
}

