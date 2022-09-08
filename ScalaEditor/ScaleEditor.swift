//
//  ScaleEditor.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI

struct ScaleEditor: View {
        
    @Binding var scale: Scale
    

    enum Field: Hashable {
        case noteName(UUID)
        case pitchValue(UUID)
        case centsRatioOptions(UUID)
    }
    
    @FocusState private var focusField: Field?
    
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        //formatter.generatesDecimalNumbers = true
        return formatter
    }()
    
    var body: some View {
        Form {
            nameSection
            descriptionSection
            notesSection
        }
    }
    var nameSection: some View {
        Section {
            TextField("Name", text: $scale.name)
                .disableAutocorrection(true)
        } header: {
            Text("Name")
        }
    }
    var descriptionSection: some View {
        Section {
            TextField("Description of the Scale", text: $scale.description)
                .lineLimit(2)
        } header: {
            Text("Description")
        }
    }
    
//    @State var numberOfNotes = 0
//
//    var numberOfNotesSection: some View {
//        Stepper {
//            Text("Notes")
//        } onIncrement: {
//            if numberOfNotes == 0 {
//                numberOfNotes = scale.notes.count
//            }
//            numberOfNotes += 1
//        } onDecrement: {
//            if numberOfNotes == 0 {
//                numberOfNotes = scale.notes.count
//            }
//            numberOfNotes -= 1
//        }
//    }
    
    // @State var displayCents = true
    
    var notesSection: some View {
        Section {
            List {
                Button {
                    print("""
! meanquar.scl
!
1/4-comma meantone scale. Pietro Aaron's temperament (1523)
 12
!
 76.04900
 193.15686
 310.26471
 5/4
 503.42157
 579.47057
 696.57843
 25/16
 889.73529
 1006.84314
 1082.89214
 2/1
""".scale ?? "unsuccessful")
                    
                } label: {
                    Text("Print")
                }
                ForEach(scale.notes) { note in
                    makeNotesRow(for: note)
                }
                .onDelete { indexSet in
                    scale.notes.remove(atOffsets: indexSet)
                }
                AnimatedActionButton(title: "Add new note", systemImage: "plus.circle.fill") {
                    scale.addPlaceholderNote()
                }
            }
        } header: {
            HStack {
                Text("Note Names")
                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
                Text("Pitch Values")
                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
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
        } footer: {
            Text("Learn more about the .scl file format at https://www.huygens-fokker.org/scala/scl_format.html.")
        }
    }
    
    @State private var globalRatioMode = false
        
//    {
//        didSet {
//            print(globalRatioMode)
//            for note in scale.notes {
//                scale.notes[note].ratioMode = globalRatioMode
//            }
//        }
//    }
    
    
    private func makeNotesRow(for note: Scale.Note) -> some View {
        return HStack {
            if let index = scale.notes.index(matching: note) {
                TextField("Degree \(index)", text: $scale.notes[note].name)
                    .disableAutocorrection(true)
                    .foregroundColor(.accentColor)
                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor)
                    .focused($focusField, equals: .noteName(note.id))
                if !note.ratioMode {
                    TextField("Cents", value: $scale.notes[note].cents, formatter: numberFormatter)
                        .foregroundColor(index == 0 ? .secondary : .accentColor)
                        .disabled(index == 0 ? true : false)
                        .keyboardType(.decimalPad)
                        .frame(width: UIScreen.main.bounds.width * DrawingConstants.pitchColWidthFactor)
                        .onChange(of: focusField) { newField in
                            if let last = scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id) {
                                commitCents(for: note)
                            }
                        }
                        .focused($focusField, equals: .pitchValue(note.id))
                } else {
                    HStack {
                        TextField("", text: $scale.notes[note].numerator)
                                    .onChange(of: focusField) { newField in
                                        if let last = scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id), !scale.notes[note].denominator.isEmpty {
                                            commitRatio(for: note)
                                        }
                                    }
                                    .focused($focusField, equals: .pitchValue(note.id))
                                    .border(note.inputRatioIsValid ? .clear : .red)
                        Text(":")
                        TextField("", text: $scale.notes[note].denominator)
                                    .onChange(of: focusField) { newField in
                                        if let last = scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id), !scale.notes[note].numerator.isEmpty {
                                            commitRatio(for: note)
                                        }
                                    }
                                    .focused($focusField, equals: .pitchValue(note.id))
                                    .border(note.inputRatioIsValid ? .clear : .red)
                    }
                    .foregroundColor(index == 0 ? .secondary : (note.inputRatioIsValid ? .accentColor : Color.red))
                    .disabled(index == 0 ? true : false)
                    .keyboardType(.decimalPad)
                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.pitchColWidthFactor)
                }
                Picker("Cents or Ratio", selection: $scale.notes[note].ratioMode) {
                    Text("¢").tag(false)
                    Text(":").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(index == 0 ? true : false)
                .onChange(of: scale.notes[note].ratioMode) { newRatioMode in
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

    private func commitCents(for note: Scale.Note) {
        scale.notes[note].denominator = ""
        scale.notes[note].numerator = ""
        withAnimation {
            scale.notes.sort()
        }
    }
    
    private func commitRatio(for note: Scale.Note) {
        if let ratio = scale.notes[note].ratio {
            withAnimation {
                scale.notes[note].inputRatioIsValid = true
                scale.notes[note].cents = ratio.cents
            }
        } else {
            scale.notes[note].inputRatioIsValid = false
        }
    }
    
    private struct DrawingConstants {
        static let notesPadding: CGFloat = 2.0
        static let borderWidth: CGFloat = 0.25
        static let noteNameColWidthFactor: CGFloat = 0.3
        static let pitchColWidthFactor: CGFloat = 0.3
    }
}

struct NoteRow: View {
    var body: some View {
        Text("")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleEditor(scale: .constant(ScaleStore(named: "Preview").scales[0]))
    }
}
