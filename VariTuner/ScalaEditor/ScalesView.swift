//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI
// TODO: long press to access context menu (including options such as duplicate, delete, star, rename, edit); favorite/all scales (use a json file to initialize if no userDefault - what's the license for the scala archive?); sort by recent/alphabet; search; generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @State private var editMode: EditMode = .inactive
    
    @State private var scaleToEdit: Scale?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.scales) { scale in
                    VStack(alignment: .leading) {
                        Text(scale.name)
                        Text(scale.description)
                            .font(.caption)
                    }
                    .lineLimit(1)
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
//                    Button {
//
//                    } label: {
//                        Label("Add from...", systemImage: "doc.badge.plus")
//                    }
//                    .contextMenu {
//                        AnimatedActionButton(title: "clipboard", systemImage: "doc.on.clipboard") {
//                            pasteScala()
//                        }
//                        AnimatedActionButton(title: "new scale", systemImage: "doc") {
//                            pasteScala()
//                        }
//                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(item: $alertToShow) { alertToShow in
            alertToShow.alert()
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
}

struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {
        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
    }
}
