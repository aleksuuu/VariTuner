//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI

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
                    AnimatedActionButton(title: "Paste Scala", systemImage: "doc.on.clipboard") {
                        pasteScala()
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
    private func getTap(for scale: Scale) -> some Gesture {
        TapGesture().onEnded {
            scaleToEdit = scale
        }
    }
    @State private var alertToShow: IdentifiableAlert?
    private func pasteScala() {
        if let scl = UIPasteboard.general.string, let scale = scl.scale {
            store.scales.append(scale)
        } else {
            alertToShow = IdentifiableAlert(
                title: "Paste Scala",
                message: "There is no Scala text currently on the pasteboard.")
        }
    }
}

struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {

        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
        
    }
}
