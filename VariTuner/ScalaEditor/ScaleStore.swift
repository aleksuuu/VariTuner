//
//  ScaleStore.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import Foundation
// TODO: switch to Core Data?
class ScaleStore: ObservableObject {
    let name: String
    @Published var userScales = [Scale]() {
        didSet {
            storeInUserDefault()
        }
    }
    
    var factoryScales = [Scale]()
    
//    var scales: [Scale] {
//        userScales + factoryScales
//    }
//
    var starredScales = [Scale]()
    
    var recentScales = [Scale]()
    
    private var userDefaultsKey: String {
        "ScaleStore:" + name // prefix makes sure this key is unique
    }
    
    private func storeInUserDefault() {
        UserDefaults.standard.set(try? JSONEncoder().encode(userScales), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefault() {
        //UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedScales = try? JSONDecoder().decode(Array<Scale>.self, from: jsonData) {
            userScales = decodedScales
        }
    }
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    private func loadFactoryScales() {
        if let localData = self.readLocalFile(forName: "factoryScales"),
        let decodedScales = try? JSONDecoder().decode(Array<Scale>.self, from: localData) {
            factoryScales = decodedScales
        }
    }
    
    init(named name: String) {
        self.name = name
        loadFactoryScales()
        restoreFromUserDefault()
        if userScales.isEmpty {
            print("using built-in scales")
//            scales.insert(
//                Scale(name: "12-12_sharps",
//                  description: "12 out of 12-tET, the most boring tuning (preferring sharps)",
//                  notes: [
//                    Scale.Note(name: "C", cents: 0),
//                    Scale.Note(name: "C#", cents: 100),
//                    Scale.Note(name: "D", cents: 200),
//                    Scale.Note(name: "D#", cents: 300),
//                    Scale.Note(name: "E", cents: 400),
//                    Scale.Note(name: "F", cents: 500),
//                    Scale.Note(name: "F#", cents: 600),
//                    Scale.Note(name: "G", cents: 700),
//                    Scale.Note(name: "G#", cents: 800),
//                    Scale.Note(name: "A", cents: 900),
//                    Scale.Note(name: "A#", cents: 1000),
//                    Scale.Note(name: "B", cents: 1100),
//                    Scale.Note(name: "C", cents: 1200)
//                  ]), at: 0
//            )
        } else {
            print("successfully loaded scales from UserDefaults")
        }
    }
    
    
}
