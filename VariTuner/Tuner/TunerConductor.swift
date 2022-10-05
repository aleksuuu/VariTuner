//
//  Tuner.swift
//  VariTuner
//
//  Created by Alexander on 9/11/22.
//  Adapted from AudioKit Cookbook (https://github.com/AudioKit/Cookbook)

import AudioKit
import AudioKitEX
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

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
    let silence: Fader
    

    var tracker: PitchTap!

//    let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
//
//    let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
//    let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]

    init(scale: Scale) {
        guard let input = engine.input else { fatalError() }

        guard let device = engine.inputDevice else { fatalError() }

        initialDevice = device

        self.scale = scale
        
        mic = input
        tappableNodeA = Fader(mic)
        tappableNodeB = Fader(tappableNodeA)
        tappableNodeC = Fader(tappableNodeB)
        silence = Fader(tappableNodeC, gain: 0)
        engine.output = silence

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
//        while frequency > Float(noteFrequencies[noteFrequencies.count - 1]) {
//            frequency /= 2.0
//        }
//        while frequency < Float(noteFrequencies[0]) {
//            frequency *= 2.0
//        }
        while frequency >= Float(scale.fundamental * scale.equaveRatio) {
            frequency /= Float(scale.equaveRatio)
            equave += 1
        }

        var minDistance: Float = 10000.0
//        var index = 0
        
        var noteName = "-"
        
        for (index, note) in scale.notes.enumerated() {
            let distance = abs(Float(scale.lowestFrequencies[index]) - frequency)
            if distance < minDistance {
                noteName = note.name
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

