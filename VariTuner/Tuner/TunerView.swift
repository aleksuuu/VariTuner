//
//  TunerView.swift
//  VariTuner
//
//  Created by Alexander on 10/3/22.
//

import SwiftUI
import AudioKit

struct TunerView: View {
    //    @StateObject var conductor = TunerConductor(scale: Scale(name: "Preview", description: "Preview scale", notes: []))
    @StateObject var conductor: TunerConductor
    
    private var noteColor: Color {
        switch abs(conductor.data.deviationInCents) {
        case let d where d > 50:
            return Color.red
        case let d where d > 15:
            return Color.yellow
        default:
            return Color.green
        }
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    if conductor.data.deviationInCents < 0 {
                        Text("\(conductor.data.deviationInCents, specifier: "%0.1f") ¢")
                    }
                    Spacer()
                    if conductor.data.deviationInCents > 0 {
                        Text("+\(conductor.data.deviationInCents, specifier: "%0.1f") ¢")
                    }
                }.foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(conductor.data.noteName)")
                        .font(.custom("BravuraText", size: DrawingConstants.noteNameFontSize, relativeTo: .title2))
                        .fontWeight(.bold)
                        .foregroundColor(noteColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(conductor.data.equave == -1 ? "" : " \(conductor.data.equave)")
                        .font(.title2)
                }
            }.padding()
            
            ZStack {
                HStack {
                    if conductor.data.deviationInCents < 0 {
                        Text("\(conductor.data.freq, specifier: "%0.1f") Hz")
                    }
                    Spacer()
                    if conductor.data.deviationInCents > 0 {
                        Text("\(conductor.data.freq, specifier: "%0.1f") Hz")
                    }
                }.foregroundColor(.secondary)
                Text("\(conductor.data.roundedFreq, specifier: "%0.1f") Hz").font(.title2)
            }.padding()
            PitchScroll(scale: conductor.scale)
                .environmentObject(conductor)
            
        }
        .navigationBarTitle(conductor.scale.name)
        .onAppear {
            conductor.start()
            conductor.tracker.start()
        }
        .onDisappear {
            conductor.tracker.stop()
            conductor.stop()
        }
    }
}


struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(conductor: TunerConductor(scale: Scale(name: "Preview", description: "Preview scale", notes: [])))
    }
}
