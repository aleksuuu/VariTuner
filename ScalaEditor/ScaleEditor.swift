//
//  ScaleEditor.swift
//  Scala Editor
//
//  Created by Alexander on 8/31/22.
//

import SwiftUI

struct ScaleEditor: View {
    @Binding var scale: Scale
    @ObservedObject var cents = NumbersOnly()
    
    @State private var editMode: EditMode = .inactive
    static let screenWidth = UIScreen.main.bounds.width
    
//    private let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.generatesDecimalNumbers = true
//        return formatter
//    }()
    
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
//            TextField("Description", text: $scale.description)
            TextField("Description of the Scale", text: $scale.description)
                .font(.footnote)
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
                ForEach(scale.notes.indices, id: \.self) { index in
                    HStack {
                        TextField("Degree \(index)", text: $scale.notes[index].name)
//                            .padding(.all, DrawingConstants.notesPadding)
//                            .border(.secondary, width: DrawingConstants.borderWidth)
                            .foregroundColor(.accentColor)
                            .frame(width: DrawingConstants.noteNameColWidth)
                        if index == 0 {
                            TextField("Cents", text: $scale.notes[index].centsString)
                                .foregroundColor(.secondary)
//                                .padding(.all, DrawingConstants.notesPadding)
                                .disabled(true)
                                .frame(width: DrawingConstants.pitchColWidth)
                        } else {
                            TextField("Cents", text: $scale.notes[index].centsString)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.accentColor)
//                                .padding(.all, DrawingConstants.notesPadding)
//                                .border(.secondary, width: DrawingConstants.borderWidth)
                                .frame(width: DrawingConstants.pitchColWidth)
                        }
                    }
                }
                .onDelete { indexSet in
                    scale.notes.remove(atOffsets: indexSet)
                }
            }
        } header: {
            HStack {
                Text("Note Names")
                    .frame(width: DrawingConstants.noteNameColWidth, alignment: .leading)
                Text("Pitch Values")
                    .frame(alignment: .leading)
            }
        }
    }
    
//    private var longPressToMove: some Gesture {
//        LongPressGesture
//            .onEnded { finished in
//                self.completedLongPress = finished
//            }
//    }
    
    private struct DrawingConstants {
        static let notesPadding: CGFloat = 2.0
        static let borderWidth: CGFloat = 0.25
        static let noteNameColWidth: CGFloat = screenWidth / 2.75
        static let pitchColWidth: CGFloat = screenWidth / 3.25
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScaleEditor(scale: .constant(ScaleStore(named: "Preview").scales[0]))
    }
}
