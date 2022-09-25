//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI

enum Category {
    case all
    case user
    case starred
    case recent
}

// TODO: scrollbar swipe gesture; what's the license for the scala archive?; generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @State fileprivate var editMode: EditMode = .inactive
    
    @State fileprivate var scaleToEdit: Scale?
    
    @State private var searchText = "" // TODO: fuzzy search?
    
    @State private var scrollTarget: String?
    
    @State var refresh = false // TODO: find a more elegant solution to update star (prob unnecessary. iOS15 bug)
    
    @State var category = Category.all
    
    private let alphabet = ["#","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Cents or Ratio", selection: $category) {
                    Text("All").tag(Category.all)
                    Text("User").tag(Category.user)
                    Text("Starred").tag(Category.starred)
                    Text("Recent").tag(Category.recent)
                }
                .pickerStyle(.segmented)
                ZStack {
                    GeometryReader { geometryProxy in
                        ScrollView {
                            ScrollViewReader { scrollViewProxy in
                                List {
                                    ForEach(alphabet, id: \.self) { letter in
                                        let scalesWithSameInitial = getScalesWithSameInitial(letter)
                                        if !scalesWithSameInitial.isEmpty {
                                            Section {
                                                ForEach(scalesWithSameInitial) { scale in
                                                    let isAUserScale = store.userScales.contains(scale)
                                                    ScaleRow(scalesView: self, scale: scale)
                                                        .deleteDisabled(!isAUserScale)
                                                        .foregroundColor(isAUserScale ? .accentColor : .black)
                                                }
                                                .onDelete { indexSet in // indexSet not working?
                                                    store.userScales.remove(atOffsets: indexSet)
                                                }
                                                .sheet(item: $scaleToEdit) { scale in
                                                    ScaleEditor(scale: $store.userScales[scale]) // this subscript works even if it's a factory scale because in UtilityExtensions, if a subscripted item can't be found in the array, the function returns the item itself
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
                                                scaleToEdit = store.userScales[0]
                                            }
                                            AnimatedActionButton(title: "Paste From Clipboard", systemImage: "doc.on.clipboard") {
                                                pasteScala()
                                                scaleToEdit = store.userScales[0]
                                            }
                                        } label: {
                                            Label("New...", systemImage: "doc.badge.plus")
                                        }
                                    }
                                }
                                .environment(\.editMode, $editMode)
                                .frame(minHeight: geometryProxy.size.height)
                            }
                        }
                    }
                    scrollBar
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .alert(item: $alertToShow) { alertToShow in
                    alertToShow.alert()
                }
            }
            
        }
    }
    
    
    var searchResults: [Scale] {
        var visibleScales = [Scale]()
        
        switch category {
        case .all:
            visibleScales = store.factoryScales + store.userScales
        case .user:
            visibleScales = store.userScales
        case .starred:
            visibleScales = store.starredScales
        case .recent:
            visibleScales = store.recentScales
        }
        visibleScales.sort()
        if searchText.isEmpty {
            return visibleScales
        } else {
            return visibleScales.filter { $0.contains(searchText) }
        }
    }
    
    var scrollBar: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(alphabet, id: \.self) { letter in
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
            store.userScales.insert(scale, at: 0)
        } else {
            alertToShow = IdentifiableAlert(
                title: "Paste Scala",
                message: "There is no Scala text currently on the clipboard.")
        }
    }
    
    private func addScale() {
        store.userScales.insert(Scale(name: "untitled", description: "", notes: [Scale.Note(cents: 0)]), at: 0)
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
                scalesView.scaleToEdit = scalesView.store.userScales[0]
            }
            if scalesView.store.starredScales.contains(scale) {
                AnimatedActionButton(title: "Starred", systemImage: "star.fill") {
                    scalesView.store.starredScales.remove(scale) // bug: update to iOS16
                }
            } else {
                AnimatedActionButton(title: "Star", systemImage: "star") {
                    scalesView.store.starredScales.insert(scale, at: 0)
                }
            }
            if scalesView.store.userScales.contains(scale) {
                AnimatedActionButton(title: "Edit", systemImage: "pencil") {
                    scalesView.scaleToEdit = scalesView.store.userScales[scale]
                }
                AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
                    scalesView.store.userScales.remove(scalesView.store.userScales[scale])
                }
                .foregroundColor(.red)
            } else {
                AnimatedActionButton(title: "Inspect", systemImage: "eye") {
                    scalesView.scaleToEdit = scalesView.store.userScales[scale]
                }
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
        scalesView.store.userScales.insert(Scale(name: name, description: scale.description, notes: scale.notes), at: 0)
    }
}


struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {
        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
            .previewDevice("iPhone 8")
    }
}
