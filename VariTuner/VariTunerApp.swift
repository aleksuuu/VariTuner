//
//  VariTunerApp.swift
//  VariTuner
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI
//import AudioKit
import AVFoundation
//import MicrophonePitchDetector

// TODO: fix "Attempted to scroll the collection view to an out-of-bounds item" [looks like it crashes when list items are not overflowing; unless there're precisely 3 or 5 items in which case it also doesn't crash] [so the problem seems to actually be caused by the switching of categories https://developer.apple.com/forums/thread/712510
// launch the app in tuner view; change to SQLite?? (https://www.reddit.com/r/SwiftUI/comments/ho0mlm/comment/fxezjbp/?context=3); recent tab should display scales in chronological order;

@main
struct VariTunerApp: App {
    @StateObject var scaleStore = ScaleStore(named: "Default")
//    @StateObject var alerter = Alerter()
    init() {
#if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch let err {
            print(err)
        }
#endif
    }
    var body: some Scene {
        WindowGroup {
            ScalesView(selectedID: scaleStore.recentScaleIDs.first)
                .environmentObject(scaleStore)
        }
    }
}

