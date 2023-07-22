//
//  VariTunerApp.swift
//  VariTuner
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI
import AVFoundation

// TODO: fix "Attempted to scroll the collection view to an out-of-bounds item" [looks like it crashes when list items are not overflowing; unless there're precisely 3 or 5 items in which case it also doesn't crash] [so the problem seems to actually be caused by the switching of categories https://developer.apple.com/forums/thread/712510
// launch the app in tuner view; change to SQLite?? (https://www.reddit.com/r/SwiftUI/comments/ho0mlm/comment/fxezjbp/?context=3); recent tab should display scales in chronological order;

// https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_route_changes
// https://stackoverflow.com/questions/45741473/change-audio-to-bluetooth-device-and-back
// https://stackoverflow.com/questions/52390659/avaudiosession-how-to-switch-between-speaker-and-headphones-output
// https://stackoverflow.com/questions/55910290/avaudiosession-defaulttospeaker-changes-mic-input

@main
struct VariTunerApp: App {
    @StateObject var scaleStore = ScaleStore(named: "Default")
    var body: some Scene {
        WindowGroup {
            ScalesView()
                .environmentObject(scaleStore)
        }
    }
}

