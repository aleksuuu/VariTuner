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
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Frequency")
                Spacer()
                Text("\(conductor.data.pitch, specifier: "%0.1f")")
            }.padding()
            
            HStack {
                Text("Note Name")
                Spacer()
                Text("\(conductor.data.noteName)")
                    .font(.custom("BravuraText", size: DrawingConstants.noteNameFontSize, relativeTo: .body))
                + Text(conductor.data.equave == -1 ? "" : "\(conductor.data.equave)")
                    .font(.caption)
                    .baselineOffset(-4.0)
            }.padding()
            HStack {
                Text("Deviation in Hz")
                Spacer()
                Text("\(conductor.data.deviation, specifier: "%0.1f")")
            }.padding()
            HStack {
                Text("Deviation in Cents")
                Spacer()
                Text("\(conductor.data.deviationInCents, specifier: "%0.1f")")
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
