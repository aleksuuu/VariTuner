//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI
// TODO: favorite/all scales (use a json file to initialize if no userDefault - what's the license for the scala archive?); sort by recent/alphabet; search; generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @State private var editMode: EditMode = .inactive
    
    @State private var scaleToEdit: Scale?
    
    @State private var searchText = "" // TODO: fuzzy search?
    
    @State var refresh = false // TODO: find a more elegant solution to update star (prob unnecessary. iOS15 bug)
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults) { scale in
                    VStack(alignment: .leading) {
                        Text(scale.name)
                            .fontWeight(scale.isStarred ? .semibold : .regular)
                        Text(scale.description)
                            .font(.caption)
                    }
                    .lineLimit(1)
                    .contextMenu {
                        AnimatedActionButton(title: "Duplicate", systemImage: "doc.on.doc.fill") {
                            duplicateScale(scale)
                            scaleToEdit = store.scales[0]
                        }
                        if store.scales[scale].isStarred {
                            AnimatedActionButton(title: "Starred", systemImage: "star.fill") {
                                store.scales[scale].isStarred = false // bug: update to iOS16
                            }
                        } else {
                            AnimatedActionButton(title: "Star", systemImage: "star") {
                                store.scales[scale].isStarred = true
                            }
                        }
                        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
                            scaleToEdit = store.scales[scale]
                        }
                        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
                            store.scales.remove(store.scales[scale])
                        }
                    }
                    .gesture(editMode == .active ? getTap(for: scale) : nil)
                }
                .onDelete { indexSet in
                    store.scales.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.scales.move(fromOffsets: indexSet, toOffset: newOffset)
                }
                .sheet(item: $scaleToEdit) { scale in
                    ScaleEditor(scale: $store.scales[scale])
                        .wrappedInNavigationViewToMakeDismissable { scaleToEdit = nil }
                }
            }
            .searchable(text: $searchText, prompt: "Search with scale name or description")
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .navigationTitle("Scales")
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
//                    AnimatedActionButton(title: "Add...", systemImage: "doc.badge.plus") {
//
//                    }
                    Menu {
                        AnimatedActionButton(title: "Create a New Scale", systemImage: "doc") {
                            addScale()
                            scaleToEdit = store.scales[0]
                        }
                        AnimatedActionButton(title: "Paste From Clipboard", systemImage: "doc.on.clipboard") {
                            pasteScala()
                            scaleToEdit = store.scales[0]
                        }
                    } label: {
                        Label("New...", systemImage: "doc.badge.plus")
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(item: $alertToShow) { alertToShow in
            alertToShow.alert()
        }
    }
    var searchResults: [Scale] {
        if searchText.isEmpty {
            return store.scales
        } else {
            return store.scales.filter { $0.contains(searchText) }
        }
    }
    private func getTap(for scale: Scale) -> some Gesture {
        TapGesture().onEnded {
            scaleToEdit = scale
        }
    }
    @State private var alertToShow: IdentifiableAlert?
    private func pasteScala() {
        if let scl = UIPasteboard.general.string, let scale = scl.scale {
            store.scales.insert(scale, at: 0)
        } else {
            alertToShow = IdentifiableAlert(
                title: "Paste Scala",
                message: "There is no Scala text currently on the clipboard.")
        }
    }
    
    private func addScale() {
        store.scales.insert(Scale(name: "untitled", description: "", notes: [Scale.Note(cents: 0)]), at: 0)
    }
    
    private func duplicateScale(_ scale: Scale) {
        let name = scale.name + "_dup"
        store.scales.insert(Scale(name: name, description: scale.description, notes: scale.notes), at: 0)
    }
}

struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {
        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
    }
}
