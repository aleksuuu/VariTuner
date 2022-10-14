//
//  ScaleStore.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import Foundation
import Combine
// TODO: switch to Core Data?
class ScaleStore: ObservableObject {
    let name: String
    var userScales = [Scale]() {
        didSet {
            UserDefaults.standard.set(try? JSONEncoder().encode(userScales), forKey: userDefaultsKey + "user")
        }
    }
    
    let alphabet = ["#","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    var factoryScales = [Scale]()
    
    var starredScaleIDs = [UUID]() {
        didSet {
            UserDefaults.standard.set(try? JSONEncoder().encode(starredScaleIDs), forKey: userDefaultsKey + "starred")
        }
    }
    
    var recentScaleIDs = [UUID]() {
        didSet {
            UserDefaults.standard.set(try? JSONEncoder().encode(recentScaleIDs), forKey: userDefaultsKey + "recent")
        }
    }
    
    @Published var searchText = ""
    @Published var sorted: [String: [Scale]] = [:]
    @Published var sortedAndFiltered: [String: [Scale]] = [:]
//    @Published var category = Category.all
//    {
//        willSet {
//            Task { @MainActor in
//                load(category: category)
//            }
//        }
//    }
    
    private var userDefaultsKey: String {
        "ScaleStore:" + name // prefix makes sure this key is unique
    }
    
    
    private func restoreFromUserDefault() {
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey + "user")
//        UserDefaults.standard.removeObject(forKey: userDefaultsKey + "starred")
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey + "user"),
           let decodedScales = try? JSONDecoder().decode(Array<Scale>.self, from: jsonData) {
            userScales = decodedScales
        }
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey + "starred"),
           let decodedScales = try? JSONDecoder().decode(Array<UUID>.self, from: jsonData) {
            starredScaleIDs = decodedScales
        }
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey + "recent"),
           let decodedScales = try? JSONDecoder().decode(Array<UUID>.self, from: jsonData) {
            recentScaleIDs = decodedScales
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
        } else {
            print("Parsing failed")
        }
    }
    
//    private func loadFactoryScales() {
//        let asset = NSDataAsset(name: "Data", bundle: Bundle.main)
//        if let json = try? JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments),
//           let decodedScales = json as? [Scale] {
//            factoryScales = decodedScales
//        } else {
//            print("Parsing failed")
//        }
//    }
    
    private func loadTestScales() {
        userScales.insert(
            Scale(name: "12-12_sharps",
                  description: "12 out of 12-tET, the most boring tuning (preferring sharps)",
                  notes: [
                    Scale.Note(name: "C", cents: 0),
                    Scale.Note(name: "C \u{E262}", cents: 100),
                    Scale.Note(name: "D", cents: 200),
                    Scale.Note(name: "D \u{E262}", cents: 300),
                    Scale.Note(name: "E", cents: 400),
                    Scale.Note(name: "F", cents: 500),
                    Scale.Note(name: "F \u{E262}", cents: 600),
                    Scale.Note(name: "G", cents: 700),
                    Scale.Note(name: "G \u{E262}", cents: 800),
                    Scale.Note(name: "A", cents: 900),
                    Scale.Note(name: "A \u{E262}", cents: 1000),
                    Scale.Note(name: "B", cents: 1100),
                    Scale.Note(name: "C", cents: 1200)
                  ]), at: 0
        )
        userScales.insert(
            Scale(name: "24-24_sharps",
                  description: "24 out of 24-tET (preferring sharps)",
                  notes: [
                    Scale.Note(name: "C", cents: 0),
                    Scale.Note(name: "C \u{E282}", cents: 50),
                    Scale.Note(name: "C \u{E262}", cents: 100),
                    Scale.Note(name: "C \u{E283}", cents: 150),
                    Scale.Note(name: "D", cents: 200),
                    Scale.Note(name: "D \u{E282}", cents: 250),
                    Scale.Note(name: "D \u{E262}", cents: 300),
                    Scale.Note(name: "D \u{E283}", cents: 350),
                    Scale.Note(name: "E", cents: 400),
                    Scale.Note(name: "E \u{E282}", cents: 450),
                    Scale.Note(name: "F", cents: 500),
                    Scale.Note(name: "F \u{E282}", cents: 550),
                    Scale.Note(name: "F \u{E262}", cents: 600),
                    Scale.Note(name: "F \u{E283}", cents: 650),
                    Scale.Note(name: "G", cents: 700),
                    Scale.Note(name: "G \u{E282}", cents: 750),
                    Scale.Note(name: "G \u{E262}", cents: 800),
                    Scale.Note(name: "G \u{E283}", cents: 850),
                    Scale.Note(name: "A", cents: 900),
                    Scale.Note(name: "A \u{E282}", cents: 950),
                    Scale.Note(name: "A \u{E262}", cents: 1000),
                    Scale.Note(name: "A \u{E283}", cents: 1050),
                    Scale.Note(name: "B", cents: 1100),
                    Scale.Note(name: "B \u{E282}", cents: 1150),
                    Scale.Note(name: "C", cents: 1200)
                  ]), at: 0
        )
    }
    
    init(named name: String) {
        self.name = name
        if factoryScales.isEmpty {
            loadFactoryScales()
        }
        restoreFromUserDefault()
        if userScales.isEmpty {
            loadTestScales()
            print("using built-in scales")
        } else {
            print("successfully loaded scales from UserDefaults")
        }
        $searchText
            .debounce(for: 0.4, scheduler: RunLoop.main) // wait for user to stop typing
            .receive(on: DispatchQueue.global()) // perform filter on background
            .map { [weak self] filterString in
                guard let self = self else {
                    return [:]
                }
                if filterString.isEmpty { return self.sorted } else {
                    var filteredDict: [String: [Scale]] = [:]
                    for initial in self.sorted.keys {
                        filteredDict[initial] = self.sorted[initial]!.filter { $0.contains(filterString) }
                    }
                    return filteredDict
                }
            }
            .receive(on: RunLoop.main) // switch back to uithread
            .assign(to: &$sortedAndFiltered)
//        $category
//            .receive(on: DispatchQueue.global())
//            .map { [weak self] category in
//                guard let self = self else { return [:] }
//                Task { @MainActor in
//                    self.load(category: category)
//                }
//
//                return self.sorted
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$sortedAndFiltered)
    }
    
    func load(category: Category) {
        var scales: [Scale] = []
        switch category {
        case .all:
            scales = userScales + factoryScales
        case .user:
            scales = userScales
        case .starred:
            scales = (userScales + factoryScales).filter { starredScaleIDs.contains($0.id) }
        case .recent:
            scales = (userScales + factoryScales).filter { recentScaleIDs.contains($0.id) }
        }
        for initial in alphabet {
            var scalesWithSameInitial: [Scale] = []
            if initial == "#" {
                scalesWithSameInitial = scales.filter { !($0.name.first?.isLetter ?? false) }
            } else {
                scalesWithSameInitial = scales.filter { $0.name.hasPrefix(initial) }
            }
            sorted[initial] = scalesWithSameInitial.sorted()
        }
        searchText = searchText
    }
    
    // MARK: - Intent(s)
    
    func addToRecent(scale: Scale) {
        if !recentScaleIDs.contains(scale.id) {
            recentScaleIDs.insert(scale.id, at: 0)
            while recentScaleIDs.count > 15 {
                recentScaleIDs.removeLast()
            }
        }
    }
    
}
