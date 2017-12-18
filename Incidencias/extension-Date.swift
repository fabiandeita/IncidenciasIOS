//
//  extension-Date.swift
//  Incidencias
//
//  Created by VaD on 26/01/16.
//  Copyright © 2016 PICIE. All rights reserved.
//

import Foundation
extension Date {
    init?(jsonDate: String) {
        
        let prefix = "/Date("
        let suffix = ")/"
        // Check for correct format:
        if jsonDate.hasPrefix(prefix) && jsonDate.hasSuffix(suffix) {
            // Extract the number as a string:
            let from = jsonDate.characters.index(jsonDate.startIndex, offsetBy: prefix.characters.count)
            let to = jsonDate.characters.index(jsonDate.endIndex, offsetBy: -suffix.characters.count)
            // Convert milleseconds to double
            guard let milliSeconds = Double(jsonDate[from ..< to]) else {
                return nil
            }
            // Create NSDate with this UNIX timestamp
            self.init(timeIntervalSince1970: milliSeconds/1000.0)
        } else {
            return nil
        }
    }
}
