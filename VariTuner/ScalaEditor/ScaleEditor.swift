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
    
    @State fileprivate var notesWithInvalidRatios: Set<Scale.Note> = []
    
    fileprivate var viewOnly: Bool {
        !store.userScales.contains(scale)
    }
    
    
    enum Field: Hashable {
        case noteName(UUID)
        case cents(UUID)
        case numerator(UUID)
        case denominator(UUID)
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
                commitCentsOrRatio()
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
        } // the reason why .onChange is here is because for .onChange to detect a change in focusField it has to be attached to something that has a focusField binding, and attaching it to this TextField prevents .onChange to fire more than once as it would happen if it were attached to every NoteRow
        .onChange(of: focusField) { newField in
            //            if let last = scale.notes.last, newField != .noteName(last.id), newField != .cents(last.id), newField != .numerator(last.id), newField != .denominator(last.id) {
            commitCentsOrRatio()
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
    
    @State private var showCentsForAll = true
    
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
                    store.refresh()
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
                    Picker("Cents or Ratio", selection: $showCentsForAll) {
                        Text("¢").tag(true)
                        Text(":").tag(false)
                    }
                    .disabled(viewOnly)
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showCentsForAll) { newShowCentsForAll in
                        withAnimation {
                            for note in scale.notes {
                                scale.notes[note].showCents = newShowCentsForAll
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
    
    
    fileprivate func commitCents(for note: Scale.Note) {
        sortAndRemoveError(for: note)
        scale.notes[note].denominator = ""
        scale.notes[note].numerator = ""
    }
    
    fileprivate func commitRatio(for note: Scale.Note) {
        if let cents = UtilityFuncs.getCentsFromRatio(numerator: note.numerator, denominator: note.denominator) {
            scale.notes[note].cents = cents
            sortAndRemoveError(for: note)
        } else {
            notesWithInvalidRatios.insert(note)
        }
    }
    
    private func sortAndRemoveError(for note: Scale.Note) {
        withAnimation {
            scale.notes.sort()
            notesWithInvalidRatios.remove(note)
        }
    }
    
    private func commitCentsOrRatio() {
        switch focusField {
        case .cents(let id):
            if let note = scale.notes.first(where: { $0.id == id }) {
                commitCents(for: note)
            }
        case .numerator(let id), .denominator(let id):
            if let note = scale.notes.first(where: { $0.id == id }) {
                commitRatio(for: note)
            }
        default:
            break
        }
    }
}

struct NoteRow: View {
    var scaleEditor: ScaleEditor
    var note: Scale.Note
    
    @State private var showCents = true
    private var inputRatioIsValid: Bool {
        !scaleEditor.notesWithInvalidRatios.contains(note)
    }
    
    private var index: Int? {
        scaleEditor.scale.notes.index(matching: note)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Group {
                    if let index = index {
                        TextField("\(index)̂", text: scaleEditor.$scale.notes[note].name)
                            .font(.custom("BravuraText", size: DrawingConstants.editorNoteNameFontSize, relativeTo: .body))
                            .disableAutocorrection(true)
                            .foregroundColor(.accentColor)
                            .frame(width: geometry.size.width * DrawingConstants.noteNameColWidthFactor)
                            .focused(scaleEditor.$focusField, equals: .noteName(note.id))
                        Spacer()
                        if note.showCents {
                            TextField("Cents", value: scaleEditor.$scale.notes[note].cents, formatter: numberFormatter)
                                .foregroundColor(index == 0 ? .secondary : .accentColor)
                                .disabled(index == 0 ? true : false)
                                .keyboardType(.decimalPad)
                                .frame(width: geometry.size.width * DrawingConstants.pitchColWidthFactor)
                                .focused(scaleEditor.$focusField, equals: .cents(note.id))
                                .onSubmit {
                                    scaleEditor.commitCents(for: note)
                                }
                        } else {
                            HStack {
                                TextField("", text: scaleEditor.$scale.notes[note].numerator)
                                    .focused(scaleEditor.$focusField, equals: .numerator(note.id))
                                    .border(inputRatioIsValid ? .clear : .red)
                                    .onSubmit {
                                        scaleEditor.commitRatio(for: note)
                                    }
                                Text(":")
                                TextField("", text: scaleEditor.$scale.notes[note].denominator)
                                    .focused(scaleEditor.$focusField, equals: .denominator(note.id))
                                    .border(inputRatioIsValid ? .clear : .red)
                                    .onSubmit {
                                        scaleEditor.commitRatio(for: note)
                                    }
                            }
                            .foregroundColor(index == 0 ? .secondary : (inputRatioIsValid ? .accentColor : Color.red))
                            .disabled(index == 0 ? true : false)
                            .keyboardType(.decimalPad)
                            .frame(width: geometry.size.width * DrawingConstants.pitchColWidthFactor)
                        }
                        Spacer()
                        Picker("Cents or Ratio", selection: scaleEditor.$scale.notes[note].showCents) {
                            Text("¢").tag(true)
                            Text(":").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(index == 0 ? true : false)
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
        }
        .deleteDisabled(scaleEditor.viewOnly || index == 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleEditor(scale: .constant(ScaleStore(named: "Preview").userScales[0]))
            .environmentObject(ScaleStore(named: "Preview"))
    }
}
