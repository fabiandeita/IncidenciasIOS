//
//  Reporte+CoreDataProperties.swift
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

extension Reporte {

    @NSManaged var accionesRealizadas: String?
    @NSManaged var altitud: NSNumber?
    @NSManaged var fechaCreacion: NSNumber?    
    @NSManaged var descripcion: String?
    @NSManaged var fechaDefinitiva: Date?
    @NSManaged var fechaProvisional: Date?
    @NSManaged var kmFinal: NSNumber?
    @NSManaged var kmInicial: NSNumber?
    @NSManaged var latitud: NSNumber?
    @NSManaged var longitud: NSNumber?
    @NSManaged var reporteId: NSNumber?
    @NSManaged var rutaAlterna: NSNumber?
    @NSManaged var tipoVehiculo: String?
    @NSManaged var acciones: NSSet?
    @NSManaged var carretera: Carretera?
    @NSManaged var categoriaEmergencia: CategoriaEmergencia?
    @NSManaged var causaEmergencia: CausaEmergencia?
    @NSManaged var conceptos: NSSet?
    @NSManaged var dano: Dano?
    @NSManaged var entidadFederativa: EntidadFederativa?
    @NSManaged var imagenes: NSSet?
    @NSManaged var subtramo: Subtramo?
    @NSManaged var tipoEmergencia: TipoEmergencia?
    @NSManaged var tramo: Tramo?
    @NSManaged var transitabilidad: Transitabilidad?
    @NSManaged var hasBeedModified: NSNumber?


}
