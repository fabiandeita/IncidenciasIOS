//
//  Accion+CoreDataProperties.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 23/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Accion {

    @NSManaged var activo: NSNumber?
    @NSManaged var ccve: String?
    @NSManaged var ccveEmergencia: String?
    @NSManaged var descripcion: String?
    @NSManaged var fechaCreacion: Date?
    @NSManaged var icve: NSNumber?
    @NSManaged var icveEmergencia: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var transito: String?
    @NSManaged var imagenes: NSSet?
    @NSManaged var tipoVehiculo: String?
    @NSManaged var reporte: Reporte?

}
