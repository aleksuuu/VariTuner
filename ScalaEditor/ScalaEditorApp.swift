//
//  ScalaEditorApp.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI

@main
struct ScalaEditorApp: App {
    @StateObject var scaleStore = ScaleStore(named: "Default")
    var body: some Scene {
        WindowGroup {
            ScaleEditor(scale: .constant(ScaleStore(named: "Preview").scales[0]))
                .environmentObject(scaleStore)
        }
    }
}
