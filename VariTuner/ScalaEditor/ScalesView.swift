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

// TODO: scrollbar swipe gesture; generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @State fileprivate var editMode: EditMode = .inactive
    
    @State fileprivate var scaleToEdit: Scale?
//    { // TODO: why does didSet work here? shouldn't I use onChange(of:)?
//        didSet {
//            if let scale = scaleToEdit {
//                store.addToRecent(scale: scale)
//            }
//        }
//    }
    
    @State private var scrollTarget: String?
    
    @State var category = Category.all
    
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
                .onChange(of: category) { category in
                    Task {
                        store.load(category: category)
//                        store.searchText = "" // TODO: there's gotta be a better way to do this...
                    }
                }
                ZStack {
                    GeometryReader { geometryProxy in
                        ScrollView {
                            ScrollViewReader { scrollViewProxy in
                                List {
                                    scalesSection
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
                                .searchable(text: $store.searchText, prompt: "Search scale names and descriptions")
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
        .onAppear {
            if store.sorted.isEmpty {
                Task {
                    store.load(category: category)
                }
            }
        }
        
    }
    
    var emptySection: some View {
        Section {
            Text("No scales available")
        }
    }
    
    var scalesSection: some View {
        ForEach(store.alphabet, id: \.self) { initial in
            let scalesWithSameInitial = store.sortedAndFiltered[initial]
            if let scales = scalesWithSameInitial, !scales.isEmpty {
                Section {
                    ForEach(scales) { scale in
                        ScaleRow(scalesView: self, scale: scale)
                    }
                    .onDelete { indexSet in // indexSet not working? no shit..
                        deleteScale(indexSet: indexSet, scales: scales)
                    }
                    .sheet(item: $scaleToEdit) { scale in
                        ScaleEditor(scale: $store.userScales[scale]) // this subscript works even if it's a factory scale because in UtilityExtensions, if a subscripted item can't be found in the array, the function returns the item itself
                            .wrappedInNavigationViewToMakeDismissable {
                                store.addToRecent(scale: scale)
                                scaleToEdit = nil
                                Task {
                                    store.load(category: category)
                                }
                                // TODO: implement scrollTarget
                            }
                    }
                } header: {
                    Text(initial)
                }
            }
        }
    }
    
    private func deleteScale(indexSet: IndexSet, scales: [Scale]) {
//        let userScaleIndexSet = indexSet.map { store.userScales.index(matching: scales[$0]) }
//        let starredScaleIndexSet = indexSet.map { store.starredScaleIDs.firstIndex(of: scales[$0].id) }
//        let recentScaleIndexSet = indexSet.map { store.recentScales.index(matching: scales[$0]) }
        for index in indexSet {
            store.userScales.remove(scales[index])
            store.starredScaleIDs.remove(scales[index].id)
            store.recentScaleIDs.remove(scales[index].id)
        }
        Task {
            store.load(category: category)
        }
    }
    
//    var searchResults: [Scale] {
//        var visibleScales = [Scale]()
//
//        switch category {
//        case .all:
//            visibleScales = store.factoryScales + store.userScales
//        case .user:
//            visibleScales = store.userScales
//        case .starred:
//            visibleScales = store.starredScales
//        case .recent:
//            visibleScales = store.recentScales
//        }
//        visibleScales.sort()
//        if searchText.isEmpty {
//            return visibleScales
//        } else {
//            return visibleScales.filter { $0.contains(searchText) }
//        }
//    }
    
    var scrollBar: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(store.alphabet, id: \.self) { letter in
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
    
    
//    private func getScalesWithSameInitial(_ letter: String) -> [Scale] {
//        if letter == "#" {
//            return searchResults.filter { !($0.name.first?.isLetter ?? false)}
//        } else {
//            return searchResults.filter { $0.name.hasPrefix(letter) }
//        }
//    }
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
        let isUser = scalesView.store.userScales.contains(scale)
        let isStarred = scalesView.store.starredScaleIDs.contains(scale.id)
        NavigationLink(destination: TunerView(conductor: TunerConductor(scale: scale)).environmentObject(scalesView.store)) {
            VStack(alignment: .leading) {
                Text(scale.name)
                    .fontWeight(isStarred ? .semibold : .regular)
                Text(scale.description)
                    .font(.caption)
            }
            .lineLimit(1)
            .contextMenu {
                AnimatedActionButton(title: "Duplicate", systemImage: "doc.on.doc.fill") {
                    duplicateScale(scale)
                    scalesView.scaleToEdit = scalesView.store.userScales[0]
                }
                if scalesView.store.starredScaleIDs.contains(scale.id) {
                    AnimatedActionButton(title: "Unstar", systemImage: "star.slash.fill") {
                        scalesView.store.starredScaleIDs.remove(scale.id)
                    }
                } else {
                    AnimatedActionButton(title: "Star", systemImage: "star") {
                        scalesView.store.starredScaleIDs.insert(scale.id, at: 0)
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
            .foregroundColor(isUser ? .accentColor : .primary)
        }
        .navigationBarTitleDisplayMode(.inline)
        .deleteDisabled(!isUser)
        .swipeActions(edge: .leading) {
            Button {
                scalesView.scaleToEdit = scale
            } label: {
                if isUser {
                    Label("Edit", systemImage: "pencil")
                } else {
                    Label("Inspect", systemImage: "eye")
                }
            }
            .tint(.indigo)
            Group {
                if scalesView.store.starredScaleIDs.contains(scale.id) {
                    Button {
                        scalesView.store.starredScaleIDs.remove(scale.id)
                    } label: {
                        Label("Unstar", systemImage: "star.slash.fill")
                    }
                } else {
                    Button {
                        scalesView.store.starredScaleIDs.insert(scale.id, at: 0)
                    } label: {
                        Label("Star", systemImage: "star")
                    }
                }
            }.tint(.yellow)
        }
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
