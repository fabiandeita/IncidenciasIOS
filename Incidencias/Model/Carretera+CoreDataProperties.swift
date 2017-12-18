//
//  Carretera+CoreDataProperties.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 13/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Carretera {

    @NSManaged var id: NSNumber
    @NSManaged var nombre: String
    @NSManaged var entidadFederativa: EntidadFederativa
    @NSManaged var tramos: NSSet?
}
