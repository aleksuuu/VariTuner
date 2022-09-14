//
//  VariTunerApp.swift
//  VariTuner
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI
import AudioKit
import AudioKitUI
import AVFoundation
//import CookbookCommon

//class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        guard let app = notification.object as? NSApplication else {
//                    fatalError("no application object")
//    }
//    
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        // Check if your app can open the URL
//        // If it can, do something with the url and options, then return true
//        // otherwise return false
//        return false
//    }
//}



@main
struct VariTunerApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var scaleStore = ScaleStore(named: "Default")
    var body: some Scene {
        WindowGroup {
            ScalesView()
                .environmentObject(scaleStore)
        }
    }
}


//@main
//struct VariTunerApp: App {
//    init() {
//        #if os(iOS)
//            do {
//                Settings.bufferLength = .short
//                try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(Settings.bufferLength.duration)
//                try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
//                                                                options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
//                try AVAudioSession.sharedInstance().setActive(true)
//            } catch let err {
//                print(err)
//            }
//        #endif
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            TunerView()
//        }
//    }
//}

