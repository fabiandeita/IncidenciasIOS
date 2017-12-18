//
//  Concepto.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 23/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import Foundation
import CoreData

@objc(Concepto)
class Concepto: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func addImagenToConcepto(_ imagen: Imagen){
        let imagenes = self.mutableSetValue(forKey: "imagenes")
        imagenes.add(imagen)
    }

}
