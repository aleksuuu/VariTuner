//
//  ScalesView.swift
//  ScalaEditor
//
//  Created by Alexander on 9/2/22.
//

import SwiftUI



// TODO: scrollbar swipe gesture; generate scale
struct ScalesView: View {
    @EnvironmentObject var store: ScaleStore
    
    @Environment(\.isSearching) private var isSearching
    
    @State fileprivate var editMode: EditMode = .inactive
    
    @State fileprivate var scaleToEditOrInspect: Scale?
    
    @State fileprivate var alphabetScrollTarget: String?
    
    @State fileprivate var category = Category.recent
    
    @StateObject var alerter: Alerter = Alerter()
    
//    @State var selectedID: UUID?
    
    private var iOS16CrashAvoidingViewId: String { // from jimt's forum post on https://developer.apple.com/forums/thread/712510
        guard #available(iOS 16, *) else { return "-view" }
        // This prevents a iOS 16 crash when to you expand a key indicator further down the screen from the 1st one you expanded.
        // Changing the view ID causes the whole to get reloaded when ever the expanded section changes.
        return "\(category)-view"
    }
    
    var body: some View {
        scalesNavigationStack
            .alert(alerter.title, isPresented: $alerter.isPresented) {
            } message: {
                Text(alerter.message)
            }
            .onAppear {
                if store.sorted.isEmpty {
                    store.load(category: category)
                }
            }
    }
    
    var scalesNavigationStack: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScalesSection(scalesView: self)
    //                    .id(iOS16CrashAvoidingViewId)
                        .onChange(of: alphabetScrollTarget) { target in
                            if let t = target {
                                alphabetScrollTarget = nil
                                withAnimation {
                                    proxy.scrollTo(t, anchor: .center)
                                }
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .searchable(text: $store.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search scale names and descriptions")
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .navigationTitle("Scales")
                        .toolbar {
                            ToolbarItem {
                                EditButton()
                            }
                            ToolbarItem(placement: .navigationBarLeading) {
                                toolbarMenu
                            }
                        }
                        .environment(\.editMode, $editMode)
                }
                Spacer()
                categoriesSection
            }
        }
    }
    

    var categoriesSection: some View {
        Picker("Cents or Ratio", selection: $category) {
            Text("Starred").tag(Category.starred)
            Text("Recent").tag(Category.recent)
            Text("User").tag(Category.user)
            Text("All").tag(Category.all)
        }
        .pickerStyle(.segmented)
        .onChange(of: category) { category in
            store.load(category: category)
        }
    }
    
    var toolbarMenu: some View {
        Menu {
            AnimatedActionButton(title: "Create a New Scale", systemImage: "doc") {
                addScale()
                scaleToEditOrInspect = store.userScales[0]
            }
            AnimatedActionButton(title: "Paste From Clipboard", systemImage: "doc.on.clipboard") {
                pasteScala()
                scaleToEditOrInspect = store.userScales[0]
            }
        } label: {
            Label("New...", systemImage: "doc.badge.plus")
        }
    }
    
    var emptyCategory: some View {
        Section {
            Text("No scales found.")
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
}

struct ScalesSection: View {
    var scalesView: ScalesView
    @Environment(\.isSearching) private var isSearching // has to be a separate struct for this environment var to work
    
    var body: some View {
        Group {
            if scalesView.category == .recent {
                recentScales
            } else {
                List(scalesView.store.alphabet, id: \.self) { initial in
                    makeScalesByInitial(initial: initial)
                }
                .overlay {
                    if !isSearching && scalesView.category != .recent {
                        scrollBar
                    }
                }
            }
        }
        .sheet(item: scalesView.$scaleToEditOrInspect) { scale in
            ScaleEditor(scale: scalesView.$store.userScales[scale]) // this subscript works even if it's a factory scale because in UtilityExtensions, if a subscripted item can't be found in the array, the function returns the item itself
                .wrappedInNavigationViewToMakeDismissable {
                    scalesView.store.addToRecent(scale: scale)
                    scalesView.scaleToEditOrInspect = nil
                    scalesView.store.load(category: scalesView.category)
                }
        }
    }
    
    var scrollBar: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(scalesView.store.alphabet, id: \.self) { letter in
                    Button {
                        scalesView.alphabetScrollTarget = letter
                    } label: {
                        Text(letter)
                            .font(.body)
                            .frame(width: 15)
                    }
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func makeScalesByInitial(initial: String) -> some View {
        let scalesWithSameInitial = scalesView.store.sortedAndFiltered[initial]
//        let _ = print(scalesWithSameInitial?.count)
        if let scales = scalesWithSameInitial, !scales.isEmpty {
            Section {
                ForEach(scales) { scale in
                    ScaleRow(scalesView: scalesView, scale: scale)
                }
                .onDelete { indexSet in
                    deleteScale(indexSet: indexSet, scales: scales)
                }
            } header: {
                Text(initial)
            }
        } else {
            EmptyView()
        }
    }
    
    private var recentScales: some View {
        List {
            ForEach(scalesView.store.recentScaleIDs, id: \.self) { id in
                if let scale = (scalesView.store.userScales + scalesView.store.factoryScales).first(where: { $0.id == id }) {
                    ScaleRow(scalesView: scalesView, scale: scale)
                }
            }
            .onDelete { indexSet in
                deleteScaleInRecent(indexSet: indexSet)
            }
        }
    }
    
    private func deleteScale(indexSet: IndexSet, scales: [Scale]) {
        for index in indexSet {
            scalesView.store.deleteScale(scales[index])
        }
        scalesView.store.load(category: scalesView.category)
    }
    
    private func deleteScaleInRecent(indexSet: IndexSet) { // because recent scales are implemented without the alphabet scroll
        for index in indexSet {
            let scaleID = scalesView.store.recentScaleIDs[index]
            scalesView.store.starredScaleIDs.remove(scaleID)
            if let scale = scalesView.store.userScales.first(where: { $0.id == scaleID }) {
                scalesView.store.userScales.remove(scale)
            }
        }
    }
    
    
    

    
}

struct ScaleRow: View {
    var scalesView: ScalesView
    var scale: Scale
    var isUser: Bool {
        scalesView.store.userScales.contains(scale)
    }
    var isStarred: Bool {
        scalesView.store.starredScaleIDs.contains(scale.id)
    }
    var body: some View {
        NavigationLink(destination: getDestination(for: scale)) {
            navigationLabel
        }
        .deleteDisabled(!isUser)
        .swipeActions(edge: .leading) {
            starButton.tint(.yellow)
            duplicateButton.tint(.teal)
            editInspectButton.tint(.indigo)
        }
    }
    
    var navigationLabel: some View {
        VStack(alignment: .leading) {
            Text(scale.name)
                .fontWeight(isStarred ? .semibold : .regular)
            Text(scale.description)
                .font(.caption)
        }
        .lineLimit(1)
        .contextMenu {
            scaleContextMenu
        }
        .gesture(scalesView.editMode == .active ? getTap(for: scale) : nil)
        .foregroundColor(isUser ? .accentColor : .primary)
    }
    
    @ViewBuilder
    var scaleContextMenu: some View {
        duplicateButton
        starButton
        editInspectButton
        if scalesView.store.userScales.contains(scale) { deleteButton }
    }
    
    var duplicateButton: some View {
        AnimatedActionButton(title: "Duplicate", systemImage: "doc.on.doc.fill") {
            scalesView.store.duplicateScale(scale)
            scalesView.scaleToEditOrInspect = scalesView.store.userScales[0]
        }
    }
    
    var starButton: some View {
        let isStarred = scalesView.store.starredScaleIDs.contains(scale.id)
        return AnimatedActionButton(title: isStarred ? "Unstar" : "Star",
                             systemImage: isStarred ? "star.slash.fill" : "star") {
            scalesView.store.toggleStar(for: scale)
            scalesView.store.load(category: scalesView.category)
        }
    }
    
    var editInspectButton: some View {
        let isUser = scalesView.store.userScales.contains(scale)
        return AnimatedActionButton(title: isUser ? "Edit" : "Inspect",
                             systemImage: isUser ? "pencil" : "eye") {
            scalesView.scaleToEditOrInspect = scale
        }
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            scalesView.store.deleteScale(scale)
            scalesView.store.load(category: scalesView.category)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func getTap(for scale: Scale) -> some Gesture {
        TapGesture().onEnded {
            scalesView.scaleToEditOrInspect = scale
        }
    }
    
    private func getDestination(for scale: Scale) -> some View {
        TunerView(conductor: TunerConductor(scale: scale))
            .environmentObject(scalesView.store)
            .environmentObject(scalesView.alerter)
    }
    

}


struct ScalesView_Previews: PreviewProvider {
    static var previews: some View {
        ScalesView()
            .environmentObject(ScaleStore(named: "Preview"))
            .previewDevice("iPhone 8")
            
    }
}
