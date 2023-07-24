//
//  ScaleStore.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import Foundation
import Combine

enum Category {
    case all
    case user
    case starred
    case recent
}

class ScaleStore: ObservableObject {
    let storeName: String
    @Published var userScales = [Scale]() {
        didSet {
            saveToFile(fileName: "userScales", content: userScales)
        }
    }
    let alphabet = ["#","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    var factoryScales = [Scale]()
    
    var starredScaleIDs = [UUID]() {
        didSet {
            saveToFile(fileName: "starredScaleIDs", content: starredScaleIDs)
        }
    }
    
    var recentScaleIDs = [UUID]() {
        didSet {
            saveToFile(fileName: "recentScaleIDs", content: recentScaleIDs)
        }
    }
    
    @Published var searchText = ""
    var sorted: [String: [Scale]] = [:]
    @Published var sortedAndFiltered: [String: [Scale]] = [:]
    
    
    private func getData(for fileName: String) -> Data? {
        if let furl = getFurl(for: fileName) {
            return try? Data(contentsOf: furl)
        }
        return nil
    }
    
    private func getFurl(for fileName: String) -> URL? {
        do {
             return try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(fileName)
                .appendingPathExtension("json")
        } catch {
            print("Error getting file url: \(error)")
        }
        return nil
    }
    
    private func loadFromDocuments() {
        if let data = getData(for: "userScales") {
            userScales = decodeFromJson(data: data) ?? []
        }
        if let data = getData(for: "starredScaleIDs") {
            starredScaleIDs = decodeFromJson(data: data) ?? []
        }
        if let data = getData(for: "recentScaleIDs") {
            recentScaleIDs = decodeFromJson(data: data) ?? []
        }
    }
    
    private func saveToFile<T: Encodable>(fileName: String, content: [T]) {
        do {
            if let furl = getFurl(for: fileName) {
                let data = try JSONEncoder().encode(content)
                try data.write(to: furl)
            }
        } catch {
            print("Error saving to file: \(error)")
        }
    }
    
    private func decodeFromJson<T: Decodable>(data: Data) -> Array<T>? {
        return try? JSONDecoder().decode(Array<T>.self, from: data)
    }
    
    private func loadFromBundle(fileName: String) {
        guard let file = Bundle.main.url(forResource: fileName, withExtension: "json")
        else {
            fatalError("Couldn't find \(fileName) in main bundle")
        }
        if let data = try? Data(contentsOf: file) {
            factoryScales = decodeFromJson(data: data) ?? []
        }
    }
    
    // for testing
    private func clearDocumentDir() {
        let fileManager = FileManager.default
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
              let filePaths = try fileManager.contentsOfDirectory(atPath: documents)
              for filePath in filePaths {
                  try fileManager.removeItem(atPath: documents + "/" + filePath)
              }
          } catch {
              print("Could not clear document folder: \(error)")
          }
    }
    
    init(named name: String) {
        self.storeName = name
        clearDocumentDir() // TODO: remove this after testing
        loadFromBundle(fileName: "factoryScales")
        loadFromDocuments()
        $searchText
            .debounce(for: 0.1, scheduler: RunLoop.main) // wait for user to stop typing
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
        recentScaleIDs.remove(scale.id) // remove removes an element if it exists, otherwise it does nothing
        recentScaleIDs.insert(scale.id, at: 0)
        while recentScaleIDs.count > 15 {
            recentScaleIDs.removeLast()
        }
    }
    
    func duplicateScale(_ scale: Scale) {
        let name = scale.name + "_dup"
        var newNotes = [Scale.Note]()
        for note in scale.notes {
            newNotes.append(Scale.Note(name: note.name, cents: note.cents, numerator: note.numerator, denominator: note.denominator, showCents: note.showCents))
        }
        userScales.insert(Scale(name: name, description: scale.description, notes: newNotes), at: 0)
    }
    
    func toggleStar(for scale: Scale) {
        if starredScaleIDs.contains(scale.id) {
            starredScaleIDs.remove(scale.id)
        } else {
            starredScaleIDs.insert(scale.id, at: 0)
        }
    }
    func deleteScale(_ scale: Scale) {
        userScales.remove(scale)
        starredScaleIDs.remove(scale.id)
        recentScaleIDs.remove(scale.id)
    }
    func refresh() {
        searchText = searchText
    }
    
}
