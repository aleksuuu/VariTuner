//
//  PitchScroll.swift
//  VariTuner
//
//  Created by Alexander on 10/6/22.
//

import SwiftUI

struct PitchScroll: View {
    @StateObject var generator = ToneGenerator()
    var scale: Scale

//    var name: String
//    var frequency: Double
    
    

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(scale.notes) { note in
                    makePitchButton(note: note)
                }
            }
        }
    }
    
    private func makePitchButton(note: Scale.Note) -> some View {
        Button {
            generator.currentFreq = note.cents.centsToFreq(lowerFreq: scale.fundamental)
        } label: {
            Text(note.name.isEmpty ? "\(scale.notes.index(matching: note) ?? 0)" : note.name)
                .font(.custom("BravuraText", size: DrawingConstants.noteNameFontSize, relativeTo: .body))
        }
    }
}

struct PitchButton_Previews: PreviewProvider {
    static var previews: some View {
        PitchScroll(scale: Scale(name: "preview", description: "preview scale", notes: []))
    }
}
