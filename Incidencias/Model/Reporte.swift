//
//  Reporte.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 23/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import Foundation
import CoreData


class Reporte: NSManagedObject {

    func addImagenToReporte(_ imagen: Imagen){
        let imagenes = self.mutableSetValue(forKey: "imagenes")
        imagenes.add(imagen)
    }
}
