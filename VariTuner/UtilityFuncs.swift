//
//  UtilityFuncs.swift
//  SqliteTest
//
//  Created by Alexander on 6/16/23.
//

import Foundation

struct UtilityFuncs {
    static func ratioIsValid(numerator: String, denominator: String) -> Bool {
        if let num = Int(numerator), let denom = Int(denominator) {
            if denom != 0 && num >= denom { return true }
        }
        return false
    }
    static func getCentsFromRatio(numerator: String, denominator: String) -> Double? {
        if let num = Int(numerator), let denom = Int(denominator) {
            if denom != 0 && num >= denom { return 1200 * log2(Double(num) / Double(denom)) }
            
            // 1200 * log2(Double(numerator) / Double(denominator))
        }
        return nil
    }
}
