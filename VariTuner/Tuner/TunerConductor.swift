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
import AVFoundation
//import MicrophonePitchDetector


// TODO: Prevent an empty scale from crashing this view

class TunerConductor: ObservableObject {
    @Published var data = TunerData()
    
    var scale: Scale
    
    private let engine = AudioEngine()
    private var hasMicrophoneAccess = false
    var showMicrophoneAccessAlert = false
    

    var tracker: PitchTap!

    @Published var currentFreq: Double? { // TODO: when two notes share the same frequency, currently the second note would stop the first note
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
        self.scale = scale
//        setUpAudioSession()
        engine.output = tone
        tone.start()
        checkMicrophoneAuthorizationStatus()
        setUpAudioSession()
    }

    private func checkMicrophoneAuthorizationStatus() { // modified from ZenTuner
        guard !hasMicrophoneAccess else { return }
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // The user has previously granted access to the microphone.
            self.setUpPitchTracking()
        case .notDetermined: // The user has not yet been asked for microphone access.
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    self.setUpPitchTracking()
                } else {
                    self.showMicrophoneAccessAlert = true
                    return
                }
            }
        case .denied: // The user has previously denied access.
            self.showMicrophoneAccessAlert = true
            return
        case .restricted: // The user can't grant access due to restrictions.
            self.showMicrophoneAccessAlert = true
            return
        @unknown default:
            self.showMicrophoneAccessAlert = true
            return
        }
    }
    
    private func setUpPitchTracking() {
        if let input = engine.input {
            input.start()
            tracker = PitchTap(input) { pitch, amp in
                DispatchQueue.main.async {
                    self.update(pitch[0], amp[0])
                }
            }
        }
        hasMicrophoneAccess = true
        start()
    }
    
    private func setUpAudioSession() {
        do {
//            Settings.bufferLength = .short
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
//            try session.setPreferredIOBufferDuration(Settings.bufferLength.duration)
//            try session.setPreferredIOBufferDuration(4096)
//            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
        } catch {
            fatalError("Failed to configure and activate session.")
        }
    }
    
    func start() {
        guard hasMicrophoneAccess else { return }
        do {
            
            try engine.start()
//            setUpAudioSession()
            tracker.start()
        } catch let err {
            print(err)
        }
    }
    
    func stop() {
        engine.stop()
    }
    
    
    private func update(_ pitch: AUValue, _ amp: AUValue) {
        // Reduces sensitivity to background noise to prevent random / fluctuating data.
        
        guard amp > 0.1 && pitch > Float(scale.fundamental) && pitch > 30 else { return }
        
        data.freq = pitch
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
            let deviation = frequency - freqToCompare
            if abs(deviation) < abs(minDeviation) {
                noteName = note.name.isEmpty ? "\(index)̂" : note.name
                minDeviation = deviation
                closestFrequency = freqToCompare
            }
        }
        data.roundedFreq = closestFrequency * pow(2, Float(equave))
        data.noteName = "\(noteName)"
        data.equave = equave
//        data.deviation = minDeviation * pow(2, Float(equave))
    }
}

