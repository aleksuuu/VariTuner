//
//  ScaleEditor.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI
import UniformTypeIdentifiers

private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    //formatter.generatesDecimalNumbers = true
    return formatter
}()

// TODO: either add geometryreader or change size to fixed values

struct ScaleEditor: View {
    
    @Binding var scale: Scale
    
    @EnvironmentObject var store: ScaleStore
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var viewOnly: Bool {
        !store.userScales.contains(scale)
    }
    
    
    enum Field: Hashable {
        case noteName(UUID)
        case pitchValue(UUID)
        case centsRatioOptions(UUID)
    }
    
    @FocusState var focusField: Field?
    
    var body: some View {
        VStack {
            Form {
                if viewOnly {
                    viewOnlyDescription
                }
                copyButton
//                starButton
//                duplicateButton
                nameSection
                    .disabled(viewOnly)
                descriptionSection
                    .disabled(viewOnly)
                tuningSection
                    .disabled(viewOnly)
                notesSection
            }
        }
    }
    
    var viewOnlyDescription: some View {
        Section {
        } footer: {
            Text("To edit this view-only factory scale, make a duplicate.")
        }
    }
    
    var copyButton: some View {
        Section {
            Button {
                UIPasteboard.general.setValue(scale.sclString,
                                              forPasteboardType: UTType.plainText.identifier)
            } label: {
                Label("Copy to Clipboard as .scl Plaintext", systemImage: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
    }
    
//    var starButton: some View {
//        Section {
//            if scale.isStarred {
//                Button {
//                    scale.isStarred = false
//                } label: {
//                    Label("Starred", systemImage: "star.fill")
//                }
//            } else {
//                Button {
//                    scale.isStarred = true
//                } label: {
//                    Label("Star", systemImage: "star")
//                }
//            }
//        }
//    }
//
//    var duplicateButton: some View {
//        Section {
//            Button {
//
//            } label: {
//                Label("Duplicate to Edit", systemImage: "doc.on.doc.fill")
//            }
//        }
//    }
    
    var nameSection: some View {
        Section {
            TextField("Name", text: $scale.name)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .foregroundColor(.accentColor)
        } header: {
            Text("Name")
        }
    }
    var descriptionSection: some View {
        Section {
            TextField("Description of the Scale", text: $scale.description)
                //.lineLimit(2)
                .foregroundColor(.accentColor)
        } header: {
            Text("Description")
        }
    }
    
    var tuningSection: some View {
        Section {
            HStack {
                TextField("Frequency", value: $scale.degreeOneTuning, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .foregroundColor(.accentColor)
                Text("Hz")
            }
        } header: {
            Text("Middle Degree 1 Frequency")
        } footer: {
            Text("The frequency of the first scale degree in the middle of the range. (When A4 = 440 Hz, C4 = 261.63 Hz.)")
        }
    }
    
    var notesSection: some View {
        Section {
            List {
                ForEach(scale.notes) { note in
                    NoteRow(scaleEditor: self, note: note)
                }
                .onDelete { indexSet in
                    scale.notes.remove(atOffsets: indexSet)
                }
                AnimatedActionButton(title: "Add new note", systemImage: "plus.circle.fill") {
                    scale.addPlaceholderNote()
                    // TODO: ability to focus on the new textfield and sort scale when a new note is added (without sorting the new note until the user clicks away from the new note)
                }
            }
            .disabled(viewOnly)
            // TODO: https://stackoverflow.com/questions/59003612/extend-swiftui-keyboard-with-custom-button
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    if case .noteName = focusField {
//                        Button("test") {
//
//                        }
//                        Button("test2") {
//
//                        }
//                    }
//                }
//            }
        } header: {
            HStack {
//                Spacer()
                Text("Note Names")
//                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
                    .frame(width: ScaleEditor.DrawingConstants.noteNameColWidth)
                Spacer()
                Text("Pitch Values")
//                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
                    .frame(width: ScaleEditor.DrawingConstants.pitchColWidth)
                Spacer()
                Picker("Cents or Ratio", selection: $globalRatioMode) {
                    Text("¢").tag(false)
                    Text(":").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: ScaleEditor.DrawingConstants.pickerColWidth)
                .onChange(of: globalRatioMode) { newRatioMode in
                    withAnimation {
                        for note in scale.notes {
                            scale.notes[note].ratioMode = newRatioMode
                        }
                    }
                }
//                Spacer()
            }
        } footer: {
            Text("Learn more about the .scl file format at https://www.huygens-fokker.org/scala/scl_format.html.")
        }
    }
    
    @State private var globalRatioMode = false
    
    struct DrawingConstants {
        static let notesPadding: CGFloat = 2.0
        static let borderWidth: CGFloat = 0.25
//        static let noteNameColWidthFactor: CGFloat = 0.3
//        static let pitchColWidthFactor: CGFloat = 0.3
        static let noteNameColWidth: CGFloat = 120
        static let pitchColWidth: CGFloat = 120
        static let pickerColWidth: CGFloat = 90
//        static let notesSectionWidth: CGFloat = 330
    }
    
}

struct NoteRow: View {
    var scaleEditor: ScaleEditor
    var note: Scale.Note
    
    // TODO: decide what to keep in the Model and what is UI that belongs here in the View; add multiselect and duplicate option
    @State private var ratioMode = false
    @State private var inputRatioIsValid = true
    
    var body: some View {
        HStack {
            if let index = scaleEditor.scale.notes.index(matching: note) {
//                Spacer()
                TextField("Degree \(index)", text: scaleEditor.$scale.notes[note].name)
                    .disableAutocorrection(true)
                    .foregroundColor(.accentColor)
//                    .frame(width: UIScreen.main.bounds.width * ScaleEditor.DrawingConstants.noteNameColWidthFactor)
                    .frame(width: ScaleEditor.DrawingConstants.noteNameColWidth)
                    .focused(scaleEditor.$focusField, equals: .noteName(note.id))
                Spacer()
                if !note.ratioMode {
                    TextField("Cents", value: scaleEditor.$scale.notes[note].cents, formatter: numberFormatter)
                        .foregroundColor(index == 0 ? .secondary : .accentColor)
                        .disabled(index == 0 ? true : false)
                        .keyboardType(.decimalPad)
//                        .frame(width: UIScreen.main.bounds.width * ScaleEditor.DrawingConstants.pitchColWidthFactor)
                        .frame(width: ScaleEditor.DrawingConstants.pitchColWidth)
                        .onChange(of: scaleEditor.focusField) { newField in
                            if let last = scaleEditor.scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id) {
                                commitCents(for: note)
                            }
                        }
                        .focused(scaleEditor.$focusField, equals: .pitchValue(note.id))
                } else {
                    HStack {
                        TextField("", text: scaleEditor.$scale.notes[note].numerator)
                            .onChange(of: scaleEditor.focusField) { newField in
                                if let last = scaleEditor.scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id), !scaleEditor.scale.notes[note].denominator.isEmpty {
                                    commitRatio(for: note)
                                }
                            }
                            .focused(scaleEditor.$focusField, equals: .pitchValue(note.id))
                            .border(inputRatioIsValid ? .clear : .red)
                        Text(":")
                        TextField("", text: scaleEditor.$scale.notes[note].denominator)
                            .onChange(of: scaleEditor.focusField) { newField in
                                if let last = scaleEditor.scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id), !scaleEditor.scale.notes[note].numerator.isEmpty {
                                    commitRatio(for: note)
                                }
                            }
                            .focused(scaleEditor.$focusField, equals: .pitchValue(note.id))
                            .border(inputRatioIsValid ? .clear : .red)
                    }
                    .foregroundColor(index == 0 ? .secondary : (inputRatioIsValid ? .accentColor : Color.red))
                    .disabled(index == 0 ? true : false)
                    .keyboardType(.decimalPad)
//                    .frame(width: UIScreen.main.bounds.width * ScaleEditor.DrawingConstants.pitchColWidthFactor)
                    .frame(width: ScaleEditor.DrawingConstants.pitchColWidth)
                }
                Spacer()
                Picker("Cents or Ratio", selection: scaleEditor.$scale.notes[note].ratioMode) {
                    Text("¢").tag(false)
                    Text(":").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: ScaleEditor.DrawingConstants.pickerColWidth)
                .disabled(index == 0 ? true : false)
                .onChange(of: ratioMode) { newRatioMode in // TODO: is this doing anything??
                    if newRatioMode {
                        commitCents(for: note)
                    } else {
                        commitRatio(for: note)
                    }
                }
//                Spacer()
            }
        }
        .textFieldStyle(.roundedBorder)
        .deleteDisabled(scaleEditor.viewOnly)
    }
    private func commitCents(for note: Scale.Note) {
        withAnimation {
            scaleEditor.scale.notes.sort()
        }
        scaleEditor.scale.notes[note].denominator = ""
        scaleEditor.scale.notes[note].numerator = ""
        inputRatioIsValid = true
    }
    
    private func commitRatio(for note: Scale.Note) {
        if let ratio = scaleEditor.scale.notes[note].ratio {
            withAnimation {
                inputRatioIsValid = true
                scaleEditor.scale.notes[note].cents = ratio.cents
            }
        } else {
            inputRatioIsValid = false
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleEditor(scale: .constant(ScaleStore(named: "Preview").userScales[0]))
            .environmentObject(ScaleStore(named: "Preview"))
    }
}
