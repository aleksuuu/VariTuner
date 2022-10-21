//
//  Alerter.swift
//  VariTuner
//
//  Created by Alexander on 10/17/22.
//

import Foundation
import SwiftUI

class Alerter: ObservableObject {
    var title = ""
    
    var message = ""
    
    @Published var isPresented = false
}
