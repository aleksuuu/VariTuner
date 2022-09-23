//
//  ScrollBarTest.swift
//  VariTuner
//
//  Created by Alexander on 9/22/22.
//

import SwiftUI

struct ScrollBarTest: View {
    var alphabet = ["#","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ForEach(0..<alphabet.count, id: \.self) { idx in
                    Button(action: {
//                        withAnimation {
//                            scrollViewProxy.scrollTo(alphabet[idx])
//                        }
                    }, label: {
                        Text(alphabet[idx])
                            .font(.caption)
                    })
                }
                Spacer()
            }
            //.frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

struct ScrollBarTest_Previews: PreviewProvider {
    static var previews: some View {
        ScrollBarTest()
    }
}
