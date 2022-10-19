//
//  Alerter.swift
//  VariTuner
//
//  Created by Alexander on 10/17/22.
//

import Foundation
import SwiftUI

class Alerter: ObservableObject {
//    @Published var alert: Alert? {
//        didSet { isShowingAlert = alert != nil }
//    }
//    @Published var isShowingAlert = false
    
    // @Published var alertToShow: IdentifiableAlert?
    
    var title = ""
    
    var message = ""
    
    @Published var isPresented = false
}
