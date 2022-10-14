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
    return formatter
}()

struct ScaleEditor: View {
    @Binding var scale: Scale
    
    @EnvironmentObject var store: ScaleStore
    
    
    var viewOnly: Bool {
        !store.userScales.contains(scale)
    }
    
    
    enum Field: Hashable {
        case noteName(UUID)
        case pitchValue(UUID)
        case centsRatioOptions(UUID)
        case anotherTextField
    }
    
    @FocusState var focusField: Field?
    
    var body: some View {
        VStack {
            Form {
                if viewOnly {
                    viewOnlyDescription
                }
                copyButton
                nameSection
                    .disabled(viewOnly)
                descriptionSection
                    .disabled(viewOnly)
                tuningSection
                    .disabled(viewOnly)
                notesSection
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) { keyboardToolbar }
            }
        }
    }
    
    var keyboardToolbar: some View {
        Group {
            if case let .noteName(id) = focusField {
                if let currentNote = scale.notes.first(where: { $0.id == id }) {
                    Group {
                        Button {
                            scale.notes[currentNote].name.append(" \u{E260}")
                        } label: {
                            Text("\u{E260}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E262}")
                        } label: {
                            Text("\u{E262}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E270}")
                        } label: {
                            Text("\u{E270}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E271}")
                        } label: {
                            Text("\u{E271}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E274}")
                        } label: {
                            Text("\u{E274}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E275}")
                        } label: {
                            Text("\u{E275}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E280}")
                        } label: {
                            Text("\u{E280}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E281}")
                        } label: {
                            Text("\u{E281}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E282}")
                        } label: {
                            Text("\u{E282}")
                        }
                        Button {
                            scale.notes[currentNote].name.append(" \u{E283}")
                        } label: {
                            Text("\u{E283}")
                        }
                    }
                    .font(.custom("BravuraText", size: DrawingConstants.accidentalFontSize, relativeTo: .body))
                }
            }
            Spacer()
            Button("Done") {
                focusField = nil
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
    
    var nameSection: some View {
        Section {
            TextField("Name", text: $scale.name)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .foregroundColor(.accentColor)
                .focused($focusField, equals: .anotherTextField)
        } header: {
            Text("Name")
        }
    }
    var descriptionSection: some View {
        Section {
            TextField("Description of the Scale", text: $scale.description)
                .foregroundColor(.accentColor)
                .focused($focusField, equals: .anotherTextField)
        } header: {
            Text("Description")
        }
    }
    
    var tuningSection: some View {
        Section {
            HStack {
                TextField("Fundamental Frequency", value: $scale.fundamental, formatter: numberFormatter)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .foregroundColor(.accentColor)
                    .focused($focusField, equals: .anotherTextField)
                Text("Hz")
            }
        } header: {
            Text("Fundamental Frequency")
        } footer: {
            Text("The frequency of the first scale degree in the zeroth equave (e.g., in 12edo, when A4 = 440 Hz, C0 = 16.35 Hz).")
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
        } header: {
            GeometryReader { geometry in
                HStack {
                    Text("Note Names")
                        .frame(width: geometry.size.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
                    Spacer()
                    Text("Pitch Values")
                        .frame(width: geometry.size.width * DrawingConstants.pitchColWidthFactor, alignment: .leading)
                    Spacer()
                    Picker("Cents or Ratio", selection: $globalRatioMode) {
                        Text("¢").tag(false)
                        Text(":").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: globalRatioMode) { newRatioMode in
                        withAnimation {
                            for note in scale.notes {
                                scale.notes[note].ratioMode = newRatioMode
                            }
                        }
                    }
                }
            }
            .padding(.bottom)
        } footer: {
            Text("Learn more about the .scl file format at https://www.huygens-fokker.org/scala/scl_format.html.")
        }
        
        
    }
    
    @State private var globalRatioMode = false
    
    //    struct DrawingConstants {
    //        static let notesPadding: CGFloat = 2.0
    //        static let borderWidth: CGFloat = 0.25
    //        static let noteNameColWidthFactor: CGFloat = 0.35
    //        static let pitchColWidthFactor: CGFloat = 0.35
    //        static let accidentalFontSize: CGFloat = 28
    //        static let editorNoteNameFontSize: CGFloat = 18
    //    }
    
}

struct NoteRow: View {
    var scaleEditor: ScaleEditor
    var note: Scale.Note
    //    var width: CGFloat
    
    @State private var ratioMode = false
    @State private var inputRatioIsValid = true
    
    private var index: Int? {
        scaleEditor.scale.notes.index(matching: note)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                if let index = index {
                    TextField("\(index)̂", text: scaleEditor.$scale.notes[note].name)
                        .font(.custom("BravuraText", size: DrawingConstants.editorNoteNameFontSize, relativeTo: .body))
                        .disableAutocorrection(true)
                        .foregroundColor(.accentColor)
                        .frame(width: geometry.size.width * DrawingConstants.noteNameColWidthFactor)
                        .focused(scaleEditor.$focusField, equals: .noteName(note.id))
                    Spacer()
                    if !note.ratioMode {
                        TextField("Cents", value: scaleEditor.$scale.notes[note].cents, formatter: numberFormatter)
                            .foregroundColor(index == 0 ? .secondary : .accentColor)
                            .disabled(index == 0 ? true : false)
                            .keyboardType(.decimalPad)
                            .frame(width: geometry.size.width * DrawingConstants.pitchColWidthFactor)
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
                        .frame(width: geometry.size.width * DrawingConstants.pitchColWidthFactor)
                    }
                    Spacer()
                    Picker("Cents or Ratio", selection: scaleEditor.$scale.notes[note].ratioMode) {
                        Text("¢").tag(false)
                        Text(":").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(index == 0 ? true : false)
                    .onChange(of: ratioMode) { newRatioMode in // TODO: is this doing anything??
                        if newRatioMode {
                            commitCents(for: note)
                        } else {
                            commitRatio(for: note)
                        }
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
        }
        .deleteDisabled(scaleEditor.viewOnly || index == 0)
    }
    private func commitCents(for note: Scale.Note) {
        withAnimation { // TODO: currently not working; possibly because UserScales is no longer published?
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
