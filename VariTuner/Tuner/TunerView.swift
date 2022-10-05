//
//  TunerView.swift
//  VariTuner
//
//  Created by Alexander on 10/3/22.
//

import SwiftUI
import AudioKit
import AudioKitUI

struct TunerView: View {
    @StateObject var conductor = TunerConductor(scale: Scale(name: "Preview", description: "Preview scale", notes: []))

    var body: some View {
        VStack {
            HStack {
                Text("Frequency")
                Spacer()
//                let _ = print(conductor.data.pitch)
                Text("\(conductor.data.pitch, specifier: "%0.1f")")
            }.padding()

            HStack {
                Text("Amplitude")
                Spacer()
                Text("\(conductor.data.amplitude, specifier: "%0.1f")")
            }.padding()

            HStack {
                Text("Note Name")
                Spacer()
                Text("\(conductor.data.noteName)")
                    .font(.custom("BravuraText", size: DrawingConstants.noteNameFontSize, relativeTo: .body))
                + Text("\(conductor.data.equave)")
                    .font(.caption)
                    .baselineOffset(-4.0)
            }.padding()

            InputDevicePicker(device: conductor.initialDevice)

            NodeRollingView(conductor.tappableNodeA).clipped()

            NodeOutputView(conductor.tappableNodeB).clipped()

            NodeFFTView(conductor.tappableNodeC).clipped()
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
    struct DrawingConstants {
        static let noteNameFontSize: CGFloat = 18
    }
}

struct InputDevicePicker: View {
    @State var device: Device

    var body: some View {
        Picker("Input: \(device.deviceID)", selection: $device) {
            ForEach(getDevices(), id: \.self) {
                Text($0.deviceID)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: device, perform: setInputDevice)
    }

    func getDevices() -> [Device] {
        AudioEngine.inputDevices.compactMap { $0 }
    }

    func setInputDevice(to device: Device) {
        do {
            try AudioEngine.setInputDevice(device)
        } catch let err {
            print(err)
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView()
    }
}
