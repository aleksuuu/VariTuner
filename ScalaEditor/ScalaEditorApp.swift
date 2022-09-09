//
//  ScalaEditorApp.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI

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
struct ScalaEditorApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var scaleStore = ScaleStore(named: "Default")
    var body: some Scene {
        WindowGroup {
//            ScaleEditor(scale: .constant(scaleStore.scales[0]))
            ScalesView()
                .environmentObject(scaleStore)
        }
    }
}
