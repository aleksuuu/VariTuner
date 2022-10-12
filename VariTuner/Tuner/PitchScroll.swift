//
//  PitchScroll.swift
//  VariTuner
//
//  Created by Alexander on 10/6/22.
//

import SwiftUI

struct PitchScroll: View {
    @EnvironmentObject var conductor: TunerConductor
    var scale: Scale

    @State private var equave = 4
    
    var body: some View {
        VStack {
            equaveStepper
            Spacer()
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.pitchButtonWidth))]) {
                    ForEach(scale.notes) { note in
                        makePitchButton(note: note)
                    }
                }
            }.padding(.horizontal)
        }
    }
    
    private var equaveStepper: some View {
        Stepper {
            Text("Equave: \(equave)")
        } onIncrement: {
            equave += 1
        } onDecrement: {
            if equave > 0 {
                equave -= 1
            }
        }
        .padding(.all)
    }
    
    private func makePitchButton(note: Scale.Note) -> some View {
        let freq = note.cents.centsToHz(lowerFreq: scale.fundamental) * pow(scale.equaveRatio, Double(equave))
        var outOfBounds = false
        if freq > TuningConstants.highestFreq || freq < TuningConstants.lowestFreq {
            outOfBounds = true
        }
        return Button {
            conductor.currentFreq = freq
        } label: {
            Text(note.name.isEmpty ? "\(scale.notes.index(matching: note) ?? 0)̂" : note.name)
                .font(.custom("BravuraText", size: DrawingConstants.pitchButtonFontSize, relativeTo: .body))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(width: DrawingConstants.pitchButtonWidth, height: DrawingConstants.pitchButtonHeight)
        .cornerRadius(12)
        .disabled(outOfBounds)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(lineWidth: DrawingConstants.pitchButtonBorderLineWidth)
            .foregroundColor(DrawingConstants.pitchButtonBorderColor)
        )
        
    }
    
}

struct PitchButton_Previews: PreviewProvider {
    static var previews: some View {
        PitchScroll(scale: Scale(name: "Preview",
                                 description: "Preview",
                                 notes: [
                                   Scale.Note(name: "C", cents: 0),
                                   Scale.Note(name: "C \u{E282}", cents: 50),
                                   Scale.Note(name: "C \u{E262}", cents: 100),
                                   Scale.Note(name: "C \u{E283}", cents: 150),
                                   Scale.Note(name: "D", cents: 200),
                                   Scale.Note(name: "D \u{E282}", cents: 250),
                                   Scale.Note(name: "D \u{E262}", cents: 300),
                                   Scale.Note(name: "D \u{E283}", cents: 350),
                                   Scale.Note(name: "E", cents: 400),
                                   Scale.Note(name: "E \u{E282}", cents: 450),
                                   Scale.Note(name: "F", cents: 500),
                                   Scale.Note(name: "F \u{E282}", cents: 550),
                                   Scale.Note(name: "F \u{E262}", cents: 600),
                                   Scale.Note(name: "F \u{E283}", cents: 650),
                                   Scale.Note(name: "Gasdfqlwkj", cents: 700),
                                   Scale.Note(name: "G \u{E282}", cents: 750),
                                   Scale.Note(name: "G \u{E262}", cents: 800),
                                   Scale.Note(name: "G \u{E283}", cents: 850),
                                   Scale.Note(name: "A", cents: 900),
                                   Scale.Note(name: "A \u{E282}", cents: 950),
                                   Scale.Note(name: "A \u{E262}", cents: 1000),
                                   Scale.Note(name: "A \u{E283}", cents: 1050),
                                   Scale.Note(name: "B", cents: 1100),
                                   Scale.Note(name: "B \u{E282}", cents: 1150),
                                   Scale.Note(name: "C", cents: 1200)
                                 ])
        )
    }
}
