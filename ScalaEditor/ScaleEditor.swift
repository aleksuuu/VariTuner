//
//  ScaleEditor.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI

struct ScaleEditor: View {
        
    @Binding var scale: Scale
    //@Environment(\.horizontalSizeClass) private var horizontalSizeClass
//    @ObservedObject var cents = NumbersOnly()
    

    enum Field: Hashable {
        case noteName(Int)
        case pitchValue(Int)
    }
    
    @FocusState private var focusField: Field?
    
//    @State private var editMode: EditMode = .inactive
    
    
//     static let screenWidth = UIScreen.main.bounds.width
//
//    static let screenWidth: CGFloat {
//        if
//    }
    
    
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
    
    @State var displayCents = true
    
    var notesSection: some View {
        Section {
            List {
                ForEach(scale.notes) { note in
                    HStack {
                        if let index = scale.notes.index(matching: note) {
                            TextField("Degree \(index)", text: $scale.notes[note].name)
                                .disableAutocorrection(true)
                                .foregroundColor(.accentColor)
                                .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor)
                                .focused($focusField, equals: .noteName(note.id))
                            TextField("Cents", value: $scale.notes[note].cents, formatter: numberFormatter
//                                      ,onEditingChanged: { _ in
//                                print(note)
//                                withAnimation {
//                                    scale.notes.sort() // TODO: Animation doesn't work if the text has to be formatted into something different (e.g., user types in 1200, formatter turns it into 1,200). Maybe because the view has to be rebuilt? And animation doesn't work with FocusState? onEditingChanged is deprecated
//                                }
//                            }
                            )
                            .foregroundColor(index == 0 ? .secondary : .accentColor)
                            .disabled(index == 0 ? true : false)
                            .keyboardType(.decimalPad)
                            .frame(width: UIScreen.main.bounds.width * DrawingConstants.pitchColWidthFactor)
                            .onChange(of: focusField) { newField in
                                if let last = scale.notes.last, newField != .noteName(last.id), newField != .pitchValue(last.id) {
                                    withAnimation {
                                        scale.notes.sort() // no animation for some reason
                                    }
                                }
                            }
                            .focused($focusField, equals: .pitchValue(note.id))
                        }
                    }
                }
                .onDelete { indexSet in
                    scale.notes.remove(atOffsets: indexSet)
                }
                Button(action: {
                    withAnimation {
                        scale.addPlaceholderNote()
                    }
                }, label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add new note")
                    }
                })
            }
        } header: {
            HStack {
                Text("Note Names")
                    .frame(width: UIScreen.main.bounds.width * DrawingConstants.noteNameColWidthFactor, alignment: .leading)
                Text("Pitch Values")
                    .frame(alignment: .leading)
            }
        }
    }

    
    private struct DrawingConstants {
        static let notesPadding: CGFloat = 2.0
        static let borderWidth: CGFloat = 0.25
        static let noteNameColWidthFactor: CGFloat = 0.36
        static let pitchColWidthFactor: CGFloat = 0.3
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleEditor(scale: .constant(ScaleStore(named: "Preview").scales[0]))
    }
}
