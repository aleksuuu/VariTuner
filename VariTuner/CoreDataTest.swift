//
//  CoreDataTest.swift
//  VariTuner
//
//  Created by Alexander on 7/22/23.
//

import SwiftUI
import CoreData

class ScalesViewModel: ObservableObject {
    let container: NSPersistentContainer
    @Published var savedEntities: [ScaleEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "ScalesContainer")
        container.loadPersistentStores { (description, error) in
            if let err = error {
                print("Error loading Core Data: \(err)")
            }
        }
        fetchScales()
    }
    
    func fetchScales() {
        let request = NSFetchRequest<ScaleEntity>(entityName: "ScaleEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching: \(error)")
        }
    }
    
    func addScale(text: String) {
        let newScale = ScaleEntity(context: container.viewContext)
        newScale.name = text
        saveData()
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchScales()
        } catch {
            print("Error saving: \(error)")
        }
    }
}


struct CoreDataTest: View {
    @StateObject var vm = ScalesViewModel()
    @State var textFieldText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Add scale here...", text: $textFieldText)
            }
        }
    }
}

struct CoreDataTest_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataTest()
    }
}
