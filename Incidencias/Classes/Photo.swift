//
//  Photo.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 19/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import Foundation

class Photo {
    
    // Properties
    var name: String
    var data: Data
    
    // Methods
    init(name: String, data: Data){
        self.name = name
        self.data = data
    }
}
