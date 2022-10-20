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
    
    @State private var alphabetScrollTarget: String?
    
    @State private var scaleScrollTarget: Scale?
    
    @State fileprivate var category = Category.recent
    
    @StateObject var alerter: Alerter = Alerter()
    
    @State var selectedID: UUID?
    
    private var iOS16CrashAvoidingViewId: String { // from jimt's forum post on https://developer.apple.com/forums/thread/712510
        guard #available(iOS 16, *) else { return "-view" }
        // This prevents a iOS 16 crash when to you expand a key indicator further down the screen from the 1st one you expanded.
        // Changing the view ID causes the whole to get reloaded when ever the expanded section changes.
        return "\(category)-view"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Cents or Ratio", selection: $category) {
                    Text("Starred").tag(Category.starred)
                    Text("Recent").tag(Category.recent)
                    Text("User").tag(Category.user)
                    Text("All").tag(Category.all)
                }
                .pickerStyle(.segmented)
                .onChange(of: category) { category in
                    Task {
                        store.load(category: category)
                    }
                }
                ZStack {
                    GeometryReader { geometryProxy in
                        ScrollView {
                            ScrollViewReader { scrollViewProxy in
                                let noScales = store.sortedAndFiltered.values.allSatisfy { $0.isEmpty }
                                List {
                                    if noScales { emptyCategory }
                                    else { makeScalesSection(scrollViewProxy: scrollViewProxy) }
                                }
                                .id(iOS16CrashAvoidingViewId)
                                .onChange(of: alphabetScrollTarget) { target in
                                    if !noScales {
                                        if let target = target {
                                            alphabetScrollTarget = nil
                                            withAnimation {
                                                scrollViewProxy.scrollTo(target, anchor: .center)
                                            }
                                        }
                                    }
                                }
                                .navigationBarTitleDisplayMode(.inline)
                                //                                .onChange(of: scrollTarget) { target in
                                //                                    if let target = target {
                                //                                        scrollTarget = nil
                                //                                        withAnimation {
                                //                                            scrollViewProxy.scrollTo(target, anchor: .center)
                                //                                        }
                                //                                    }
                                //                                }
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
                    if category != .recent { scrollBar }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .alert(alerter.title, isPresented: $alerter.isPresented) {
                } message: {
                    Text(alerter.message)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if store.sorted.isEmpty {
                Task {
                    store.load(category: category)
                }
            }
        }
        
    }
    
    var emptyCategory: some View {
        Section {
            Text("No \(String(describing: category)) scales.")
        }
    }
    
//    @ViewBuilder
//    var scalesSection: some View {
//        if category == .recent {
//            Section {
//                ForEach(store.recentScaleIDs, id: \.self) { id in
//                    if let scale = (store.userScales + store.factoryScales).first(where: { $0.id == id }) {
//                        ScaleRow(scalesView: self, scale: scale)
//                    }
//                }
//                .onDelete { indexSet in
//                    deleteScaleInRecent(indexSet: indexSet)
//                }
//                .sheet(item: $scaleToEdit) { scale in
//                    ScaleEditor(scale: $store.userScales[scale])
//                        .wrappedInNavigationViewToMakeDismissable {
//                            store.addToRecent(scale: scale)
//                            scaleToEdit = nil
//                            Task {
//                                store.load(category: category)
//                            }
//                        }
//                }
//            }
//        } else {
//            ForEach(store.alphabet, id: \.self) { initial in
//                let scalesWithSameInitial = store.sortedAndFiltered[initial]
//                if let scales = scalesWithSameInitial, !scales.isEmpty {
//                    Section {
//                        ForEach(scales) { scale in
//                            ScaleRow(scalesView: self, scale: scale)
//                        }
//                        .onDelete { indexSet in
//                            deleteScale(indexSet: indexSet, scales: scales)
//                        }
//                        .onChange(of: scaleScrollTarget) { target in
//                            if let target = target {
//                                scaleScrollTarget = nil
//                                withAnimation {
//                                    scrollViewProxy.scrollTo(target, anchor: .center)
//                                }
//                            }
//                        }
//                        .sheet(item: $scaleToEdit) { scale in
//                            ScaleEditor(scale: $store.userScales[scale]) // this subscript works even if it's a factory scale because in UtilityExtensions, if a subscripted item can't be found in the array, the function returns the item itself
//                                .wrappedInNavigationViewToMakeDismissable {
//                                    store.addToRecent(scale: scale)
//                                    scaleToEdit = nil
//                                    Task {
//                                        store.load(category: category)
//                                    }
//                                    scaleScrollTarget = scale
//                                }
//                        }
//                    } header: {
//                        Text(initial)
//                    }
//                }
//            }
//        }
//    }
    
    @ViewBuilder
    private func makeScalesSection(scrollViewProxy: ScrollViewProxy) -> some View {
        if category == .recent {
            Section {
                ForEach(store.recentScaleIDs, id: \.self) { id in
                    if let scale = (store.userScales + store.factoryScales).first(where: { $0.id == id }) {
                        ScaleRow(scalesView: self, scale: scale)
                    }
                }
                .onDelete { indexSet in
                    deleteScaleInRecent(indexSet: indexSet)
                }
                .sheet(item: $scaleToEdit) { scale in
                    ScaleEditor(scale: $store.userScales[scale])
                        .wrappedInNavigationViewToMakeDismissable {
                            store.addToRecent(scale: scale)
                            scaleToEdit = nil
                            Task {
                                store.load(category: category)
                            }
                        }
                }
            }
        } else {
            ForEach(store.alphabet, id: \.self) { initial in
                let scalesWithSameInitial = store.sortedAndFiltered[initial]
                if let scales = scalesWithSameInitial, !scales.isEmpty {
                    Section {
                        ForEach(scales) { scale in
                            ScaleRow(scalesView: self, scale: scale)
                        }
                        .onDelete { indexSet in
                            deleteScale(indexSet: indexSet, scales: scales)
                        }
                        .onChange(of: scaleScrollTarget) { target in
                            if let target = target {
                                scaleScrollTarget = nil
                                withAnimation {
                                    scrollViewProxy.scrollTo(target, anchor: .center)
                                }
                            }
                        }
                        .sheet(item: $scaleToEdit) { scale in
                            ScaleEditor(scale: $store.userScales[scale]) // this subscript works even if it's a factory scale because in UtilityExtensions, if a subscripted item can't be found in the array, the function returns the item itself
                                .wrappedInNavigationViewToMakeDismissable {
                                    store.addToRecent(scale: scale)
                                    scaleToEdit = nil
                                    scaleScrollTarget = scale
                                    Task {
                                        store.load(category: category)
                                    }
                                }
                        }
                    } header: {
                        Text(initial)
                    }
                }
            }
        }
    }
    
    private func deleteScale(indexSet: IndexSet, scales: [Scale]) {
        for index in indexSet {
            store.userScales.remove(scales[index])
            store.starredScaleIDs.remove(scales[index].id)
            store.recentScaleIDs.remove(scales[index].id)
        }
        Task {
            store.load(category: category)
        }
    }
    
    private func deleteScaleInRecent(indexSet: IndexSet) { // because recent scales are implemented without the alphabet scroll
        for index in indexSet {
            let scaleID = store.recentScaleIDs[index]
            store.starredScaleIDs.remove(scaleID)
            if let scale = store.userScales.first(where: { $0.id == scaleID }) {
                store.userScales.remove(scale)
            }
        }
    }
    
    var scrollBar: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(store.alphabet, id: \.self) { letter in
                    Button {
                        alphabetScrollTarget = letter
                    } label: {
                        Text(letter)
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
    
    private func pasteScala() {
        if let scl = UIPasteboard.general.string, let scale = scl.scale {
            store.userScales.insert(scale, at: 0)
        } else {
            alerter.title = "Paste Scala"
            alerter.message = "There is no Scala text currently on the clipboard."
            alerter.isPresented = true
        }
    }
    
    private func addScale() {
        store.userScales.insert(Scale(name: "untitled", description: "", notes: [Scale.Note(cents: 0)]), at: 0)
    }
    fileprivate func starScale(_ scale: Scale) {
        store.starredScaleIDs.insert(scale.id, at: 0)
        Task {
            store.load(category: category)
        }
    }
    fileprivate func unstarScale(_ scale: Scale) {
        store.starredScaleIDs.remove(scale.id)
        Task {
            store.load(category: category)
        }
    }
}

struct ScaleRow: View {
    var scalesView: ScalesView
    var scale: Scale
    var body: some View {
        let isUser = scalesView.store.userScales.contains(scale)
        let isStarred = scalesView.store.starredScaleIDs.contains(scale.id)
        NavigationLink(destination: getDestination(for: scale), tag: scale.id, selection: scalesView.$selectedID) {
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
                        scalesView.unstarScale(scale)                    }
                } else {
                    AnimatedActionButton(title: "Star", systemImage: "star") {
                        scalesView.starScale(scale)                    }
                }
                if scalesView.store.userScales.contains(scale) {
                    AnimatedActionButton(title: "Edit", systemImage: "pencil") {
                        scalesView.scaleToEdit = scalesView.store.userScales[scale]
                    }
                    Button(role: .destructive) {
                        scalesView.store.userScales.remove(scalesView.store.userScales[scale])
                        Task {
                            scalesView.store.load(category: scalesView.category)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } else {
                    AnimatedActionButton(title: "Inspect", systemImage: "eye") {
                        scalesView.scaleToEdit = scalesView.store.userScales[scale]
                    }
                }
            }
            .gesture(scalesView.editMode == .active ? getTap(for: scale) : nil)
            .foregroundColor(isUser ? .accentColor : .primary)
        }
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
                        scalesView.unstarScale(scale)                    } label: {
                            Label("Unstar", systemImage: "star.slash.fill")
                        }
                } else {
                    Button {
                        scalesView.starScale(scale)
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
    
    private func getDestination(for scale: Scale) -> some View {
        TunerView(conductor: TunerConductor(scale: scale))
            .environmentObject(scalesView.store)
            .environmentObject(scalesView.alerter)
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
