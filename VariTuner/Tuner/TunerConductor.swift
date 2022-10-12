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
                    case _ where freq > 12000:
                        tone.parameter1 = 12000
                    case _ where freq < 30:
                        tone.parameter1 = 30
                    default:
                        tone.parameter1 = AUValue(freq)
                    }
                    print(tone.parameter1)
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
        guard amp > 0.1 else { return }
        
        guard pitch > Float(scale.fundamental) else { return }

        data.pitch = pitch
        data.amplitude = amp

        var frequency = pitch
        
        var equave = 0
        while frequency >= Float(scale.fundamental * scale.equaveRatio) {
            frequency /= Float(scale.equaveRatio)
            equave += 1
        }

        var minDistance: Float = 10000.0
        
        var noteName = "-"
        
        for (index, note) in scale.notes.enumerated() {
            let distance = abs(Float(scale.lowestFrequencies[index]) - frequency)
            if distance < minDistance {
                noteName = note.name.isEmpty ? "\(index)" : note.name
                minDistance = distance
            }
        }

//        for possibleIndex in 0 ..< scale.lowestFrequencies.count {
//            let distance = fabsf(Float(noteFrequencies[possibleIndex]) - frequency)
//            if distance < minDistance {
//                index = possibleIndex
//                minDistance = distance
//            }
//        }
        data.noteName = "\(noteName)"
        data.equave = equave
    }
}

