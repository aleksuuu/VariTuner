//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI
// TODO: all/user/starred/recent (use a json file to initialize if no userDefault - what's the license for the scala archive?); generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @State fileprivate var editMode: EditMode = .inactive
    
    @State fileprivate var scaleToEdit: Scale?
    
    @State private var searchText = "" // TODO: fuzzy search?
    
    @State private var scrollTarget: String?
    
    @State var refresh = false // TODO: find a more elegant solution to update star (prob unnecessary. iOS15 bug)
    
    private let alphabet = ["#","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometryProxy in
                    ScrollView {
                        ScrollViewReader { scrollViewProxy in
                            //                        ZStack {
                            List {
                                ForEach(alphabet, id: \.self) { letter in
                                    let scalesWithSameInitial = getScalesWithSameInitial(letter)
                                    if !scalesWithSameInitial.isEmpty {
                                        Section {
                                            ForEach(scalesWithSameInitial) { scale in
                                                ScaleRow(scalesView: self, scale: scale)
                                            }
                                            .onDelete { indexSet in
                                                store.scales.remove(atOffsets: indexSet)
                                            }
                                            .sheet(item: $scaleToEdit) { scale in
                                                ScaleEditor(scale: $store.scales[scale])
                                                    .wrappedInNavigationViewToMakeDismissable { scaleToEdit = nil }
                                            }
                                        } header: {
                                            Text(letter)
                                        }
                                    }
                                }
                            }
                            .onChange(of: scrollTarget) { target in
                                if let target = target {
                                    scrollTarget = nil
                                    withAnimation {
                                        scrollViewProxy.scrollTo(target, anchor: .center)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .searchable(text: $searchText, prompt: "Search with scale name or description")
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .navigationTitle("Scales")
                            .toolbar {
                                ToolbarItem {
                                    EditButton()
                                }
                                ToolbarItem(placement: .navigationBarLeading) {
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
                            //                            ScrollBar(scrollViewProxy: scrollViewProxy, alphabet: alphabet)
                            //}
                            .frame(minHeight: geometryProxy.size.height)
                        }
                    }
                }
                scrollBar
                
                //            List {
                //                ForEach(searchResults) { scale in
                //                    ScaleRow(scalesView: self, scale: scale)
                //                }
                //                .onDelete { indexSet in
                //                    store.scales.remove(atOffsets: indexSet)
                //                }
                //                .sheet(item: $scaleToEdit) { scale in
                //                    ScaleEditor(scale: $store.scales[scale])
                //                        .wrappedInNavigationViewToMakeDismissable { scaleToEdit = nil }
                //                }
                //            }
                //            .searchable(text: $searchText, prompt: "Search with scale name or description")
                //            .disableAutocorrection(true)
                //            .textInputAutocapitalization(.never)
                //            .navigationTitle("Scales")
                //            .toolbar {
                //                ToolbarItem {
                //                    EditButton()
                //                }
                //                ToolbarItem(placement: .navigationBarLeading) {
                //                    Menu {
                //                        AnimatedActionButton(title: "Create a New Scale", systemImage: "doc") {
                //                            addScale()
                //                            scaleToEdit = store.scales[0]
                //                        }
                //                        AnimatedActionButton(title: "Paste From Clipboard", systemImage: "doc.on.clipboard") {
                //                            pasteScala()
                //                            scaleToEdit = store.scales[0]
                //                        }
                //                    } label: {
                //                        Label("New...", systemImage: "doc.badge.plus")
                //                    }
                //                }
                //            }
                //            .environment(\.editMode, $editMode)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
        }
        
    }
    
    
    var searchResults: [Scale] {
        if searchText.isEmpty {
            return store.scales
        } else {
            return store.scales.filter { $0.contains(searchText) }
        }
    }
    
    var scrollBar: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(alphabet, id: \.self) { letter in
                    //                    Button(action: {
                    //                        withAnimation {
                    //                            scrollViewProxy.scrollTo(alphabet[idx])
                    //                        }
                    //                    }, label: {
                    //                        Text(alphabet[idx])
                    //                            .font(.caption)
                    //                    })
                    Button {
                        scrollTarget = letter
                    } label: {
                        Text(letter)
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
    
    
    private func getScalesWithSameInitial(_ letter: String) -> [Scale] {
        if letter == "#" {
            return searchResults.filter { !($0.name.first?.isLetter ?? false)}
        } else {
            return searchResults.filter { $0.name.hasPrefix(letter) }
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


struct ScrollBar: View {
    var scrollViewProxy: ScrollViewProxy
    var alphabet: [String]
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(0..<alphabet.count, id: \.self) { idx in
                    //                    Button(action: {
                    //                        withAnimation {
                    //                            scrollViewProxy.scrollTo(alphabet[idx])
                    //                        }
                    //                    }, label: {
                    //                        Text(alphabet[idx])
                    //                            .font(.caption)
                    //                    })
                    Button {
                        
                    } label: {
                        Text(alphabet[idx])
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
}
struct ScaleRow: View {
    var scalesView: ScalesView
    var scale: Scale
    var body: some View {
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
                scalesView.scaleToEdit = scalesView.store.scales[0]
            }
            if scalesView.store.scales[scale].isStarred {
                AnimatedActionButton(title: "Starred", systemImage: "star.fill") {
                    scalesView.store.scales[scale].isStarred = false // bug: update to iOS16
                }
            } else {
                AnimatedActionButton(title: "Star", systemImage: "star") {
                    scalesView.store.scales[scale].isStarred = true
                }
            }
            AnimatedActionButton(title: "Edit", systemImage: "pencil") {
                scalesView.scaleToEdit = scalesView.store.scales[scale]
            }
            AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
                scalesView.store.scales.remove(scalesView.store.scales[scale])
            }
        }
        .gesture(scalesView.editMode == .active ? getTap(for: scale) : nil)
    }
    private func getTap(for scale: Scale) -> some Gesture {
        TapGesture().onEnded {
            scalesView.scaleToEdit = scale
        }
    }
    private func duplicateScale(_ scale: Scale) {
        let name = scale.name + "_dup"
        scalesView.store.scales.insert(Scale(name: name, description: scale.description, notes: scale.notes), at: 0)
    }
}


struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {
        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
            .previewDevice("iPhone 8")
    }
}
