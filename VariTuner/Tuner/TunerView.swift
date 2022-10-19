//
//  TunerView.swift
//  VariTuner
//
//  Created by Alexander on 10/3/22.
//

import SwiftUI
import AudioKit
import AVFoundation

struct TunerView: View {
    @StateObject var conductor: TunerConductor
    @EnvironmentObject var store: ScaleStore
    @EnvironmentObject var alerter: Alerter
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                let devXOffset = getXOffset(deviation: conductor.data
                    .deviationInCents, geometry: geometry)
                if let xOffset = devXOffset {
                    Text("\(conductor.data.deviationInCents! > 0 ? "+" : "")\(conductor.data.deviationInCents!, specifier: "%0.1f") ¢")
                        .foregroundColor(.secondary)
                        .frame(width: geometry.size.width)
                        .offset(x: xOffset)
                        .animation(.easeInOut, value: conductor.data.deviationInCents)
                } else {
                    Text(" ")
                }
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(conductor.data.noteName)")
                        .font(.custom("BravuraText", size: DrawingConstants.tunerNoteNameFontSize, relativeTo: .title2))
                        .foregroundColor(noteColor)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(conductor.data.equave == -1 ? "" : " \(conductor.data.equave)")
                        .font(.title2)
                }.padding(.vertical, DrawingConstants.tunerPadding)
                if let xOffset = devXOffset {
                    Text("\(conductor.data.roundedFreq, specifier: "%0.1f") Hz")
                        .font(.title2)
                    Text("\(conductor.data.freq, specifier: "%0.1f") Hz")
                        .foregroundColor(.secondary)
                        .frame(width: geometry.size.width)
                        .offset(x: xOffset)
                        .animation(.easeInOut, value: conductor.data.freq)
                        .padding(.vertical, DrawingConstants.tunerPadding)
                } else {
                    Text("–")
                        .font(.title2)
                    Text(" ")
                        .foregroundColor(.secondary)
                        .padding(.vertical, DrawingConstants.tunerPadding)
                }
            
                PitchScroll(scale: conductor.scale)
                    .environmentObject(conductor)
            }
            .navigationBarTitle(conductor.scale.name)
        }
        .onAppear {
#if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = true
#endif
            conductor.start()
            if conductor.showMicrophoneAccessAlert {
                alerter.title = "Microphone Access Required"
                alerter.message = "Please grant microphone access in the Settings app in the Privacy ⇾ Microphone section."
                alerter.isPresented = true
            }
        }
        .onDisappear {
#if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = false
#endif
            conductor.stop()
            store.addToRecent(scale: conductor.scale)
        }
    }
    
    private var noteColor: Color {
        if let deviation = conductor.data.deviationInCents {
            switch abs(deviation) {
            case let d where d > 50:
                return Color.red
            case let d where d > 15:
                return Color.yellow
            default:
                return Color.green
            }
        }
        return Color.green
    }
    
    private func getXOffset(deviation: Float?, geometry: GeometryProxy) -> CGFloat? {
        switch deviation {
        case nil:
            return nil
        case _ where deviation! > 50:
            return geometry.size.width * 0.5
        case _ where deviation! < -50:
            return -geometry.size.width * 0.5
        default:
            return geometry.size.width * 0.01 * CGFloat(deviation!) // geometry.size.width * 0.5 * CGFloat(deviation!) / 50
        }
    }
}


struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(conductor: TunerConductor(scale: Scale(name: "Preview", description: "Preview scale", notes: [])))
    }
}
