  //
//  ApiHandler.swift
//  Incidencias
//
//  Created by Mobile on 4/28/16.
//  Copyright © 2016 PICIE. All rights reserved.
//

import Foundation
import Alamofire
import SVProgressHUD
  
  var golbalActionsToSync = 0
  var globalActionsCount = 0
  var globalActionsToSyncDict: [Reporte: Int] = [:]
  var globalActionsCountDict: [Reporte: Int] = [:]
  
  @objc protocol onResponseApiListener {
    func onReportFetchFinished(reporte : Reporte)
    func onAccionFetchFinished(accion: Accion)
    func onConceptFetchFinished(concepto: Concepto)
    func onImageReportFetchFinished(concepto: Concepto)
    func onReporteE7FetchFinished(responseE7: AnyObject)
    func onReporteHistoricoFetchFinished(responseHistorico: AnyObject?)
    func onImageEmergenciasFetchFinished(responseImagenes: AnyObject?)
    @objc optional func onReportDidCreate(indexPath: NSIndexPath)
  }
  class ApiHandler {
    
    static let bigInteger : Int = 15000
    static let TYPE_IMAGE_REPORT = "report_image"
    static let TYPE_IMAGE_CONCEPT = "concepto_image"
    static let TYPE_IMAGE_CROQUIS = "report_croquis"
    
    
    
    static  var onResponseApiListenerDelegate : onResponseApiListener!
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    
    
    // MARK: Variables
    
    class func createEmergencia(reporte: Reporte, indexPath: NSIndexPath) {
        
        let reporteIDValidate =  abs(reporte.reporteId as! Int)
        
        
        if reporteIDValidate >= bigInteger  {
            /* Cuando al Reporte se le ha asignado un valor del servidor esta dentro de un valor inicial de no mayor a 15000 y es positivo  en el caso contrario el reporte aun no
             ha sido enviado al servidor por lo cual aqui se procede.*/
            
            var categoriaId = -1;
            if let categoria = reporte.categoriaEmergencia{
                categoriaId = categoria.id.intValue
            }
            
            
            // Set Fechas
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let fechaProvisional = dateFormatter.string(from: reporte.fechaProvisional!)
            let fechaDefinitiva = dateFormatter.string(from: reporte.fechaDefinitiva!)
            
            
            // accion.transito
            
            // TRANS Los valores obtenidos son:  0     Nulo
            // TRANS Los valores obtenidos son:  1     Total
            // TRANS Los valores obtenidos son:  2     Provisional
            // TRANS Los valores obtenidos son:  3     Parcial
            
            print("La descripcion es : \(reporte.descripcion!)")
            print("La transitabilidad es : \(reporte.transitabilidad?.nombre)")
            
            
            var transitoID : Int = 0;
            if(reporte.transitabilidad != nil){
                
                if reporte.transitabilidad?.nombre == "Total"{
                    transitoID = 1
                }else if reporte.transitabilidad?.nombre == "Provisional"{
                    transitoID = 2
                }else if reporte.transitabilidad?.nombre == "Parcial"{
                    transitoID = 3
                }else if reporte.transitabilidad?.nombre == "Nulo"{
                    transitoID = 0
                }
            }
            
            var todoTipoVehiculo : Int = 0;
            var todoTipoAuto : Int = 0;
            var todoTipoCamiones : Int = 0;
            
            if(reporte.tipoVehiculo != nil){
                print("Tipo de vehiculo es :  \(reporte.tipoVehiculo!)")
                
                if reporte.tipoVehiculo! == "Todo tipo"{
                    todoTipoVehiculo = 1
                }else if reporte.tipoVehiculo! == "Autos"{
                    todoTipoAuto = 1
                }else if reporte.tipoVehiculo! == "Camiones"{
                    todoTipoCamiones = 1
                }
            }
            
            
            
            
            // TODO Revisar el tema de camiones autos todo tipo
            let parameters: [String: AnyObject] = [
                
                "subtramoid": "\(reporte.subtramo!.id.intValue)" as AnyObject,
                "kminicial": "\(Double(reporte.kmInicial!) * 1000)" as AnyObject,
                "kmfinal": "\(Double(reporte.kmFinal!) * 1000)" as AnyObject,
                "latitud": "\(reporte.latitud!.floatValue)" as AnyObject,
                "longitud": "\(reporte.longitud!.floatValue)" as AnyObject,
                "altitud": "\(reporte.altitud!.floatValue)" as AnyObject,
                "danoid": "\(reporte.dano!.id.intValue)" as AnyObject,
                "tipoid": "\(reporte.tipoEmergencia!.id.intValue)" as AnyObject,
                "categoriaid": "\(categoriaId)" as AnyObject,
                "descripcion": "\(reporte.descripcion!)" as AnyObject,
                "transito": "\(transitoID)" as AnyObject,
                "vehiculostransitanautos": "\(todoTipoAuto)" as AnyObject,
                "vehiculostransitancamiones": "\(todoTipoCamiones)" as AnyObject,
                "vehiculostransitantodotipo": "\(todoTipoVehiculo)" as AnyObject,
                "fechaprovisional": fechaProvisional as AnyObject,
                "fechadefinitiva": fechaDefinitiva as AnyObject,
                "entidadfederativaid": (reporte.entidadFederativa?.id)! as AnyObject,
                "rutaalternativa": reporte.rutaAlterna as AnyObject,
                "emergencia": "\(0)" as AnyObject,
                "accionesrealizadas": "\(reporte.accionesRealizadas!)" as AnyObject,
                "activo": "1" as AnyObject
            ]
            
            //print("Parameters: \(parameters)")
            var JSON: NSString!
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            }catch{
                print("json error: \(error as NSError)")
            }
            
            let data = ["data1": JSON] as Parameters
            print("Data: \(data)")
            
            // Send Reort to Server
            Alamofire.request("\(URL_REPORTES)\(SERVICIO_EMERGENCIA_CREATE)", method: .post ,parameters: data)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Emergencia Create ERROR: \(error.localizedDescription)")
                        onResponseApiListenerDelegate.onReportFetchFinished(reporte: reporte)
                        
                    }else{
                        print("Response JSON: \(response.result.value!)")
                        //
                        // Save Reporte ID (emergenciaid)
                        
                        // cuando el valor del response es 1     success = 1;
                        
                        
                        
                        if let valuerequest = response.result.value{
                            
                            let succesvalue = (valuerequest as AnyObject).object(forKey: "success");
                            print("Succesvalue: \(succesvalue!)")
                            
                            if((succesvalue as! NSNumber) == 1){
                                
                                
                                let dataValue = (valuerequest as AnyObject).object(forKey: "data");
                                print("Datta Value: \(dataValue!)")
                                
                                
                                if let dataValueResponse = dataValue{
                                    
                                    
                                    let emergenciaid = (dataValueResponse as AnyObject).objectAt(0).object(forKey: "emergenciaid");
                                    let fechacreacion = (dataValueResponse as AnyObject).objectAt(0).object(forKey:"fechacreacion");
                                    
                                    
                                    print("Emergencia ID: \(emergenciaid!)")
                                    print("Fecha de creacion : \(fechacreacion!)")
                                    
                                    if let number = emergenciaid as! Int? {
                                        let myNumber = NSNumber(value:number)
                                        reporte.reporteId = myNumber
                                        
                                    } else {
                                        print("'\(emergenciaid)' did not convert to an Int")
                                    }
                                    
                                    let myNumberDate : NSNumber?
                                    
                                    if let datecreation = fechacreacion as! Int? {
                                        myNumberDate = NSNumber(value:datecreation)
                                        reporte.fechaCreacion = myNumberDate
                                        
                                    } else {
                                        print("'\(fechacreacion)' did not convert to an Int")
                                    }
                                    
                                    reporte.hasBeedModified = false
                                    
                                    // Save
                                   // DispatchQueue.async(group: dispatch_get_main_queue(),execute: {
                                        do {
                                            try reporte.managedObjectContext?.save()
                                            
                                            onResponseApiListenerDelegate.onReportDidCreate!(indexPath: indexPath)
                                            executeAccionesCreate(reporte: reporte);
                                            executeConceptosCreate(reporte: reporte);
                                            
                                            
                                        } catch {
                                            fatalError("Failure to save context in emergenciaid, with error: \(error)")
                                        }
                                    //})
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
                            
                            
                        }
                    }
            }
            
        }
        else if (reporte.hasBeedModified == true){
            
            
            onResponseApiListenerDelegate.onReportDidCreate!(indexPath: indexPath)
            executeAccionesCreate(reporte: reporte);
            executeConceptosCreate(reporte: reporte);
            
            reporte.hasBeedModified = false
            
            // Save
            do {
                try reporte.managedObjectContext?.save()
                
                
            } catch {
                fatalError("Failure to save context in hasBeedModified, with error: \(error)")
            }
            
        }
        else {
            print("Nada que hacer en executeEmergenciasCreate")
            onResponseApiListenerDelegate.onReportDidCreate!(indexPath: indexPath)
        }
        
    }
    
    class func executeEmergenciasCreate(reportes : [Reporte]){
        
        globalActionsToSyncDict = [:]
        globalActionsCountDict = [:]
        
        for reporte in reportes{
            let reporteIDValidate =  abs(reporte.reporteId as! Int)
            
            var accionesNoSincronizadas = false
            let acciones = reporte.acciones!.allObjects as! [Accion]
            for accion in acciones {
                let accionesIDValidate =  abs(accion.id as! Int)
                if accionesIDValidate >= bigInteger {
                    accionesNoSincronizadas = true
                    break
                }
            }
            
            
            if reporteIDValidate >= bigInteger  {
                /* Cuando al Reporte se le ha asignado un valor del servidor esta dentro de un valor inicial de no mayor a 15000 y es positivo  en el caso contrario el reporte aun no
                 ha sido enviado al servidor por lo cual aqui se procede.*/
                
                var categoriaId = -1;
                if let categoria = reporte.categoriaEmergencia{
                    categoriaId = categoria.id.intValue
                }
                
                
                // Set Fechas
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let fechaProvisional = dateFormatter.string(from: reporte.fechaProvisional!)
                let fechaDefinitiva = dateFormatter.string(from: reporte.fechaDefinitiva!)
                
                
                // accion.transito
                
                // TRANS Los valores obtenidos son:  0     Nulo
                // TRANS Los valores obtenidos son:  1     Total
                // TRANS Los valores obtenidos son:  2     Provisional
                // TRANS Los valores obtenidos son:  3     Parcial
                
                print("La descripcion es : \(reporte.descripcion!)")
                print("La transitabilidad es : \(reporte.transitabilidad?.nombre)")
                
                
                var transitoID : Int = 0;
                if(reporte.transitabilidad != nil){
                    
                    if reporte.transitabilidad?.nombre == "Total"{
                        transitoID = 1
                    }else if reporte.transitabilidad?.nombre == "Provisional"{
                        transitoID = 2
                    }else if reporte.transitabilidad?.nombre == "Parcial"{
                        transitoID = 3
                    }else if reporte.transitabilidad?.nombre == "Nulo"{
                        transitoID = 0
                    }
                }
                
                var todoTipoVehiculo : Int = 0;
                var todoTipoAuto : Int = 0;
                var todoTipoCamiones : Int = 0;
                
                if(reporte.tipoVehiculo != nil){
                    print("Tipo de vehiculo es :  \(reporte.tipoVehiculo!)")
                    
                    if reporte.tipoVehiculo! == "Todo tipo"{
                        todoTipoVehiculo = 1
                    }else if reporte.tipoVehiculo! == "Autos"{
                        todoTipoAuto = 1
                    }else if reporte.tipoVehiculo! == "Camiones"{
                        todoTipoCamiones = 1
                    }
                }
                
                
                
                
                // TODO Revisar el tema de camiones autos todo tipo
                let parameters: [String: AnyObject] = [
                    
                    "subtramoid": "\(reporte.subtramo!.id.intValue)" as AnyObject,
                    "kminicial": "\(Double(reporte.kmInicial!) * 1000)"  as AnyObject,
                    "kmfinal": "\(Double(reporte.kmFinal!) * 1000)"  as AnyObject,
                    "latitud": "\(reporte.latitud!.floatValue)"  as AnyObject,
                    "longitud": "\(reporte.longitud!.floatValue)"  as AnyObject,
                    "altitud": "\(reporte.altitud!.floatValue)"  as AnyObject,
                    "danoid": "\(reporte.dano!.id.intValue)"  as AnyObject,
                    "tipoid": "\(reporte.tipoEmergencia!.id.intValue)"  as AnyObject,
                    "categoriaid": "\(categoriaId)"  as AnyObject,
                    "descripcion": "\(reporte.descripcion!)"  as AnyObject,
                    "transito": "\(transitoID)"  as AnyObject,
                    "vehiculostransitanautos": "\(todoTipoAuto)"  as AnyObject,
                    "vehiculostransitancamiones": "\(todoTipoCamiones)"  as AnyObject,
                    "vehiculostransitantodotipo": "\(todoTipoVehiculo)"  as AnyObject,
                    "fechaprovisional": fechaProvisional  as AnyObject,
                    "fechadefinitiva": fechaDefinitiva  as AnyObject,
                    "entidadfederativaid": (reporte.entidadFederativa?.id)!  as AnyObject,
                    "rutaalternativa": reporte.rutaAlterna  as AnyObject,
                    "emergencia": "\(0)"  as AnyObject,
                    "accionesrealizadas": "\(reporte.accionesRealizadas!)"  as AnyObject,
                    "activo": "1"  as AnyObject
                ]
                
                //print("Parameters: \(parameters)")
                var JSON: NSString!
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                }catch{
                    print("json error: \(error)")
                }
                
                let data = ["data1": JSON] as Parameters
                print("Data: \(data)")
                
                // Send Reort to Server
                Alamofire.request("\(URL_REPORTES)\(SERVICIO_EMERGENCIA_CREATE)",method: .post ,parameters: data)
                    .responseJSON { response in
                        
                        if let error = response.result.error {
                            print("Emergencia Create ERROR: \(error.localizedDescription)")
                            onResponseApiListenerDelegate.onReportFetchFinished(reporte: reporte)
                            
                        }else{
                            print("Response JSON: \(response.result.value!)")
                            //
                            // Save Reporte ID (emergenciaid)
                            
                            // cuando el valor del response es 1     success = 1;
                            
                            
                            
                            if let valuerequest = response.result.value{
                                
                                let succesvalue = (valuerequest as AnyObject).object(forKey: "success");
                                print("Succesvalue: \(succesvalue!)")
                                
                                if((succesvalue as! NSNumber) == 1){
                                    
                                    
                                    let dataValue = (valuerequest as AnyObject).object(forKey: "data");
                                    print("Datta Value: \(dataValue!)")
                                    
                                    
                                    if let dataValueResponse = dataValue{
                                        
                                        
                                        let emergenciaid = (dataValueResponse as AnyObject).objectAt(0).object(forKey: "emergenciaid");
                                        let fechacreacion = (dataValueResponse as AnyObject).objectAt(0).object(forKey:" fechacreacion");
                                        
                                        
                                        print("Emergencia ID: \(emergenciaid!)")
                                        print("Fecha de creacion : \(fechacreacion)")
                                        
                                        if let number = emergenciaid as! Int? {
                                            let myNumber = NSNumber(value:number)
                                            reporte.reporteId = myNumber
                                            
                                        } else {
                                            print("'\(emergenciaid)' did not convert to an Int")
                                        }
                                        
                                        let myNumberDate : NSNumber?
                                        
                                        if let datecreation = fechacreacion as! Int? {
                                            myNumberDate = NSNumber(value:datecreation)
                                            reporte.fechaCreacion = myNumberDate
                                            
                                        } else {
                                            print("'\(fechacreacion)' did not convert to an Int")
                                        }
                                        
                                        reporte.hasBeedModified = false
                                        
                                        // Save
                                        do {
                                            try reporte.managedObjectContext?.save()
                                            
                                            onResponseApiListenerDelegate.onReportFetchFinished(reporte: reporte)
                                            executeAccionesCreate(reporte: reporte);
                                            executeConceptosCreate(reporte: reporte);
                                            
                                            
                                        } catch {
                                            fatalError("Failure to save context in emergenciaid, with error: \(error)")
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                                
                                
                                
                            }
                        }
                }
                
            }
            else if (reporte.hasBeedModified == true || accionesNoSincronizadas){
                
                
                executeAccionesCreate(reporte: reporte);
                executeConceptosCreate(reporte: reporte);
                
                reporte.hasBeedModified = false
                
                // Save
                do {
                    try reporte.managedObjectContext?.save()
                    
                    
                } catch {
                    fatalError("Failure to save context in hasBeedModified, with error: \(error)")
                }
                
            }else{
                print("Nada que hacer en executeEmergenciasCreate")
            }
            
            
            
            
            //Set time out to avoid simultaneus inserts in DB
            usleep(10000);
        }
        
        
    }
    
    
    class func executeAccionesCreate(reporte : Reporte){
        
        
        var acciones = reporte.acciones?.allObjects as! [Accion]
        let reporteIDValidate =  abs(reporte.reporteId as! Int)
        
        acciones.sort { (a1: Accion, a2: Accion) -> Bool in
            let fecha1 = a1.fechaCreacion ?? NSDate.distantPast
            let fecha2 = a2.fechaCreacion ?? NSDate.distantPast
            return fecha1.compare(fecha2) == ComparisonResult.orderedAscending
        }
        
        //        for accion in  acciones {
        //            sendActionToWS(reporte, acciones: acciones, accion: accion, reporteIDValidate: reporteIDValidate, completion: {
        //                usleep(1);
        //            })
        //        }
        
        let accionesNoSincronizadas = acciones.filter { (accion: Accion) -> Bool in
            let accionesIDValidate =  abs(accion.id as! Int)
            return accionesIDValidate >= bigInteger
        }
        
        globalActionsToSyncDict[reporte] = accionesNoSincronizadas.count
        globalActionsCountDict[reporte] = 0
        
        if globalActionsToSyncDict[reporte]! > 0 {
            sendActionToWS(reporte: reporte, acciones: accionesNoSincronizadas, index: globalActionsCountDict[reporte]!, reporteIDValidate: reporteIDValidate, completion: {
                print("Terminamos")
            })
        }
        
        //        let actionsToSend = acciones.count
        //        var cont = 0
        //
        //        let accion = acciones.first!
        //
        //        sendActionToWS(reporte, acciones: acciones, accion: accion, reporteIDValidate: reporteIDValidate, completion: {
        //
        //        })
        
    }
    
    class func nextAction() {
        
    }
    
    class func sendActionToWS(reporte : Reporte, acciones: [Accion], index: Int, reporteIDValidate: Int, completion: (() -> Void)) {
        
        let accion = acciones[index]
        let accionesIDValidate =  abs(accion.id as! Int)
        if accionesIDValidate >= bigInteger  {
            
            /* Cuando al Reporte se le ha asignado un valor del servidor esta dentro de un valor inicial de no mayor a 15000 y es positivo por lo cual se procede a hacer el fetch de las actividades ya
             que estas dependen de un numero de reporte id valido (asignado por el servidor)*/
            
            print("El tamaño de accion es: \(reporte.acciones?.count)")
            
            print("La accion es: \(accion.descripcion)")
            
            print("El transito de la acción es: \(accion.transito)")
            
            
            
            // accion.transito
            
            // TRANS Los valores obtenidos son:  0     Nulo
            // TRANS Los valores obtenidos son:  1     Total
            // TRANS Los valores obtenidos son:  2     Provisional
            // TRANS Los valores obtenidos son:  3     Parcial
            
            var transitoID : Int = 0;
            
            
            if(accion.transito != nil){
                
                if accion.transito == "Total"{
                    transitoID = 1
                }else if accion.transito == "Provisional"{
                    transitoID = 2
                }else if accion.transito == "Parcial"{
                    transitoID = 3
                }else if accion.transito == "Nulo"{
                    transitoID = 0
                }
            }
            
            
            //TODO implementar tipo de Vehiculo en esta seccion
            var activo : String = "0"
            
            if(accion == acciones.last){
                activo = "1"
                print("the last action is the active one")
                
            }
            
            
            //TIPO DE VEHICULO
            
            var todoTipoVehiculo : Int = 0;
            var todoTipoAuto : Int = 0;
            var todoTipoCamiones : Int = 0;
            
            if(accion.tipoVehiculo != nil){
                print("Tipo de vehiculo accion es :  \(accion.tipoVehiculo!)")
                
                if accion.tipoVehiculo! == "Todo tipo"{
                    todoTipoVehiculo = 1
                }else if accion.tipoVehiculo! == "Autos"{
                    todoTipoAuto = 1
                }else if accion.tipoVehiculo! == "Camiones"{
                    todoTipoCamiones = 1
                }
            }
            
            
            
            
            let accionDict: [String: AnyObject] = [
                
                "transito": transitoID as AnyObject,
                "accion" : "\(accion.descripcion!)" as AnyObject,
                "emergenciaid": reporteIDValidate as AnyObject,
                "vehiculostransitanautos": "\(todoTipoAuto)" as AnyObject,
                "vehiculostransitancamiones": "\(todoTipoCamiones)" as AnyObject,
                "vehiculostransitantodotipo": "\(todoTipoVehiculo)" as AnyObject,
                "activo": activo as AnyObject
                
            ]
            
            var JSON: NSString!
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: accionDict, options: [])
                JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            }catch{
                print("json error: \(error)")
            }
            
            let data = ["data": JSON] as Parameters
            
            
            let actionGroup = DispatchGroup()
            actionGroup.enter()
            
            Alamofire.request( "\(URL_SERVICES)\(SERVICIO_ACCION_CREATE)", method:.post, parameters: data)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Accion Create ERROR: \(error.localizedDescription)")
                        onResponseApiListenerDelegate.onAccionFetchFinished(accion: accion)
                        
                    }else{
                        print("Response JSON: \(response.result.value!)")
                        
                        // Save Accion ID (accionid)
                        if let valuerequest = response.result.value{
                            
                            let succesvalue =  (valuerequest as AnyObject).object(forKey: "success");
                            print("Succesvalue: \(succesvalue!)")
                            
                            if((succesvalue as! NSNumber) == 1){
                                
                                let dataValue = (valuerequest as AnyObject).object(forKey: "data");
                                print("Datta Value: \(dataValue!)")
                                
                                
                                if let dataValueResponse = dataValue{
                                    
                                    
                                    let accionid = (dataValueResponse as AnyObject).objectAt(0).object(forKey: "accionid");
                                    
                                    print("Emergencia ID: \(accionid!)")
                                    
                                    let myNumber : NSNumber?
                                    
                                    if let number = accionid as! Int? {
                                        myNumber = NSNumber(value:number)
                                        accion.id = myNumber
                                        
                                    } else {
                                        print("'\(accionid)' did not convert to an Int")
                                    }
                                    
                                    // Save
                                    //dispatch_async(dispatch_get_main_queue(),{
                                        do {
                                            try accion.managedObjectContext?.save()
                                            onResponseApiListenerDelegate.onAccionFetchFinished(accion: accion)
                                        } catch {
                                            fatalError("Failure to save context in accion id, with error: \(error)")
                                        }
                                        
                                    //})
                                    
                                }
                            }
                            
                            
                        }
                    }
                   // dispatch_group_leave(actionGroup)
            }
            
            

            //dispatch_group_notify(actionGroup, dispatch_get_main_queue(), {
                // Avisamos que terminamos de descargar los folders
                print("Acción sincronizada: \(accion.descripcion)")
                if globalActionsCountDict[reporte]! == globalActionsToSyncDict[reporte]! - 1 {
                    completion()
                }
                else {
                    globalActionsCountDict[reporte]! += 1
                    sendActionToWS(reporte: reporte, acciones: acciones, index: globalActionsCountDict[reporte]!, reporteIDValidate: reporteIDValidate, completion: {
                        completion()
                    })
                }
            //})
        }
        else {
            globalActionsCountDict[reporte]! += 1
            sendActionToWS(reporte: reporte, acciones: acciones, index: globalActionsCountDict[reporte]!, reporteIDValidate: reporteIDValidate, completion: {
                completion()
            })
        }
    }
    
    class func executeConceptosCreate(reporte : Reporte){
        
        let reporteIDValidate =  abs(reporte.reporteId as! Int)
        
        let concepts = reporte.conceptos?.allObjects as! [Concepto]
        
        
        for concept in  concepts {
            let conceptIDValidate =  abs(concept.id as! Int)
            if conceptIDValidate >= bigInteger {
                print("El tamaño de conceptos es: \(concepts.count)")
                
                print("La cantidad es es: \(concept.cantidad)")
                
                print("El transito de la acción es: \(concept.ccveEmergencia)")
                
                
                /*
                 Ejemplo del concepto
                 
                 dictionary2 = @{@"actividadid":CONCEPTO.icve
                 ,@"activo":@"1"
                 ,@"emergenciaid":ICVEEMERGENCIASERVER
                 ,@"avance":[CONCEPTO.iporAvance stringValue]
                 ,@"cantidad":[CONCEPTO.cantidad stringValue]
                 ,@"empresa":@{@"empresaid":@"1"}
                 ,@"nombre":CONCEPTO.descripcion
                 ,@"unidad":[CONCEPTO.icveUnidad stringValue]
                 };  */
                var catidadValidated : NSNumber = 0
                
                if(concept.cantidad != nil){
                    catidadValidated = concept.cantidad!
                }
                
                
                // Set Fechas
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let fechaCreacion = dateFormatter.string(from: concept.fechaCreacion!)
                
                
                let conceptDict: [String: AnyObject] = [
                    "emergenciaid": reporteIDValidate as AnyObject,
                    "activo": 1 as AnyObject,
                    "fechacreacion": fechaCreacion as AnyObject,
                    "nombre": "\(concept.descripcion!)" as AnyObject,
                    "cantidad": "\(catidadValidated)" as AnyObject,
                    "unidad": "\(concept.icveUnidad!)" as AnyObject,
                    "avance": "\(concept.iporAvance!)" as AnyObject
                    
                ]
                
                print("Concepto conceptDict  \(conceptDict)")
                
                
                var JSON: NSString!
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: conceptDict, options: [])
                    JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
                }catch{
                    print("json error: \(error)")
                }
                
                let data = ["data": JSON] as Parameters
                Alamofire.request( "\(URL_SERVICES)\(SERVICIO_CONCEPTO_CREATE)",method : .post, parameters: data)
                    .responseJSON { response in
                        
                        if let error = response.result.error {
                            onResponseApiListenerDelegate.onConceptFetchFinished(concepto: concept)
                            print("Accion Create ERROR: \(error.localizedDescription)")
                            
                        }else{
                            print("Response JSON: \(response.result.value!)")
                            
                            // onResponseApiListenerDelegate.onConceptFetchFinished(concept)
                            
                            if let valuerequest = response.result.value{
                                
                                let succesvalue = (valuerequest as AnyObject).object(forKey: "success");
                                print("Succesvalue: \(succesvalue!)")
                                
                                if((succesvalue as! NSNumber) == 1){
                                    
                                    let dataValue = (valuerequest as AnyObject).object(forKey: "data");
                                    print("Datta Value: \(dataValue!)")
                                    
                                    
                                    if let dataValueResponse = dataValue{
                                        
                                        
                                        let conceptoid = (dataValueResponse as AnyObject).objectAt(0).object(forKey: "actividadid");
                                        
                                        print("Concepto ID: \(conceptoid!)")
                                        
                                        let myNumber : NSNumber?
                                        
                                        if let number = conceptoid as! Int? {
                                            myNumber = NSNumber(value:number)
                                            concept.id = myNumber
                                            
                                        } else {
                                            print("'\(conceptoid)' did not convert to an Int")
                                        }
                                        
                                       DispatchQueue.main.async {
                                        do {
                                            try concept.managedObjectContext?.save()
                                            onResponseApiListenerDelegate.onConceptFetchFinished(concepto: concept)
                                        } catch {
                                            fatalError("Failure to save context in accion id, with error: \(error)")
                                        }
                                        }
                                        
                                       /* dispatch_async(dispatch_get_main_queue(),{
                                            // Save
                                            do {
                                                try concept.managedObjectContext?.save()
                                                onResponseApiListenerDelegate.onConceptFetchFinished(concepto: concept)
                                            } catch {
                                                fatalError("Failure to save context in accion id, with error: \(error)")
                                            }
                                        })*/
                                        
                                        
                                    }
                                }
                                
                                
                            }
                            
                            // Save Concepto ID (accionid)
                        }
                }
            }
            
            
            
            
            //Set time out to avoid multiple threads.
            usleep(10000);
        }
    }
    
    
    
    
    // MARK: Funciones de las imagenes
    
    
    class func  fetchImagesForAllReports(reportes : [Reporte]){
        
        for reporte in reportes{
            
            if let images = reporte.imagenes?.allObjects as? [Imagen]{
                
                
                if images.isEmpty{
                    print("Images is Empty")
                }else{
                    
                    for image in images {
                        print("La imagen tiene type \(image.type)" )
                        
                        if image.type == 0{
                            print("La imagen con id \(image.id) es Normal" )
                            
                            
                            let imageIDValidate =  abs(image.id as! Int)
                            if imageIDValidate >= bigInteger {
                                
                                // With NSURLSession
                                let reporteIDValidate =  abs(reporte.reporteId as! Int)
                                
                                createImageRequest(type: TYPE_IMAGE_REPORT, id: reporteIDValidate ,  image: image, reporte: nil);
                                
                            }
                            
                        }
                        
                        
                    }
                }
                
                //Termina else
            }
            
            
        }
        
        
    }
    
    
    
    class func  fetchImagesForAllConcepts(reportes : [Reporte]){
        
        for reporte in reportes{
            
            
            if let conceptos = reporte.conceptos?.allObjects as? [Concepto]{
                
                
                
                if conceptos.isEmpty{
                    print("No hay conceptos para crear sus imagenes" )
                }else{
                    for concepto in conceptos{
                        
                        if let images = concepto.imagenes?.allObjects as? [Imagen]{
                            if images.isEmpty{
                                print("Images de Conceptos is Empty")
                            }else{
                                
                                for image in images {
                                    //Valdamos que sea un Croquis (1 croquis , 0 imagen normal)
                                    print("\(image.name)")
                                    let imageIDValidate =  abs(image.id as! Int)
                                    if imageIDValidate >= bigInteger {
                                        // With NSURLSession
                                        let conceptoIDValidate =  abs(concepto.id as! Int)
                                        
                                        createImageRequest(type: TYPE_IMAGE_CONCEPT, id: conceptoIDValidate ,image: image, reporte: nil);
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            
            
            //Set time out to avoid simultaneus inserts in DB
            usleep(10000);
        }
        
        
    }
    
    class func  fetchCroquisForAllReports(reportes : [Reporte]){
        
        
        for reporte in reportes{
            
            if let images = reporte.imagenes?.allObjects as? [Imagen]{
                
                
                if images.isEmpty{
                    print("Images is Empty")
                }else{
                    
                    for image in images {
                        print("La imagen tiene type \(image.type)" )
                        
                        if image.type == 1{
                            print("La imagen con id \(image.id) es Croquis" )
                            
                            
                            let imageIDValidate =  abs(image.id as! Int)
                            if imageIDValidate >= bigInteger {
                                
                                // With NSURLSession
                                let reporteIDValidate =  abs(reporte.reporteId as! Int)
                                
                                createImageRequest(type: TYPE_IMAGE_CROQUIS, id: reporteIDValidate ,  image: image, reporte: reporte);
                                
                            }
                            
                        }
                        
                        
                    }
                }
                
                //Termina else
            }
            
        }
        //Set time out to avoid simultaneus inserts in DB
        usleep(10000);
    }
    
    
    
    class func sendCroquisEmergenciaInfo(reporte : Reporte){
        
        
    }
    
    
    class func sendEmergenciaImagenInfo(id : Int , responseString : Int){
        
        let reporteIDValidate =  id
        
        //print("Response JSON: \(response.result.value!)")
        
        
        let imagenID: [String: AnyObject] = [
            "imagenid" : responseString as AnyObject
        ]
        
        
        
        let conceptDict: [String: AnyObject] = [
            "emergenciaid" : reporteIDValidate as AnyObject
            ,"imagen" : imagenID as AnyObject
        ]
        
        
        
        
        print("Emergencia imagen Create  \(conceptDict)")
        
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: conceptDict, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data": JSON] as Parameters
        
        
        
        Alamofire.request( "\(URL_SERVICES)\(SERVICIO_EMERGENCIA_IMAGEN_CREATE)",method: .post, parameters: data)
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Accion Create ERROR: \(error.localizedDescription)")
                    
                }else{
                    
                    print("Response JSON: \(response.result.value!)")
                    
                }
                
        }
        
        
    }
    
    
    
    class func sendEmergenciaCroquisInfo(id : Int , responseString : Int , reporte : Reporte?){
        
        let reporteIDValidate =  id
        
        //print("Response JSON: \(response.result.value!)")
        
        /*
         NSDictionary *dictionaryCroquisEmergencia = @{
         @"emergenciaid":ICVEEMERGENCIASERVER
         ,@"accionesrealizadas":EMERGENCIA.accionesRealizadas
         ,@"activo":@"1"
         ,@"altitud":[EMERGENCIA.altitud stringValue]
         //,@"categoriaid":[EMERGENCIA.icveCategoriaEmergencia stringValue]
         ,@"danoid":[EMERGENCIA.icveDanos stringValue]
         ,@"descripcion":EMERGENCIA.descripcion
         //,@"fechacreacion":@"1401245901000"
         ,@"fechadefinitiva":EMERGENCIA.fechaDefinitiva
         //,@"fechamodificacion":@"1401245901000"
         ,@"fechaprovisional":EMERGENCIA.fechaProvisional
         ,@"kmfinal":EMERGENCIA.kmFinal
         ,@"kminicial":EMERGENCIA.kmInicial
         ,@"latitud":[EMERGENCIA.latitud stringValue]
         //,@"libroblanco":@""
         ,@"longitud":[EMERGENCIA.longitud stringValue]
         //,@"recursos":@""
         //,@"rutaalternativa":[EMERGENCIA.rutaAlternativa stringValue]
         ,@"subtramoid":[EMERGENCIA.icveSubtramo stringValue]
         ,@"tipoid":[EMERGENCIA.icveTipoEmergencia stringValue]
         ,@"transito":[EMERGENCIA.icveTransito stringValue]
         //,@"usuarioid":@""
         ,@"vehiculostransitanautos":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"vehiculostransitancamiones":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"vehiculostransitantodotipo":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"croquisimagenid":ICVEIMAGENSERVER
         };*/
        
        // Set Fechas
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fechaProvisional = dateFormatter.string(from: reporte!.fechaProvisional!)
        let fechaDefinitiva = dateFormatter.string(from: reporte!.fechaDefinitiva!)
        
        var categoriaId = -1;
        if let categoria = reporte!.categoriaEmergencia{
            categoriaId = categoria.id.intValue
        }
        print("Fecha de creacion : \(reporte!.fechaCreacion!)")
        
        var todoTipoVehiculo : Int = 0;
        var todoTipoAuto : Int = 0;
        var todoTipoCamiones : Int = 0;
        
        if(reporte!.tipoVehiculo != nil){
            print("Tipo de vehiculo es :  \(reporte!.tipoVehiculo!)")
            
            if reporte!.tipoVehiculo == "Todo tipo"{
                todoTipoVehiculo = 1
            }else if reporte!.tipoVehiculo == "Autos"{
                todoTipoAuto = 1
            }else if reporte!.tipoVehiculo == "Camiones"{
                todoTipoCamiones = 1
            }
        }
        
        var transitabilidadFinal = "0"
        
        if let transitabilidad = reporte?.transitabilidad?.nombre.lowercased() {
            
            if transitabilidad == "nulo" {
                transitabilidadFinal = "0"
            }
            else if transitabilidad == "total" {
                transitabilidadFinal = "1"
            }
            else if transitabilidad == "provisional" {
                transitabilidadFinal = "2"
            }
            else if transitabilidad == "parcial" {
                transitabilidadFinal = "3"
            }
        }
        
        
        
        let conceptDict: [String: AnyObject] = [
            "emergenciaid": reporteIDValidate as AnyObject,
            "subtramoid": "\(reporte!.subtramo!.id.intValue)" as AnyObject,
            "kminicial": "\(Double(reporte!.kmInicial!) * 1000)" as AnyObject,
            "kmfinal": "\(Double(reporte!.kmFinal!) * 1000)"  as AnyObject,
            "latitud": "\(reporte!.latitud!.floatValue)" as AnyObject,
            "longitud": "\(reporte!.longitud!.floatValue)" as AnyObject,
            "altitud": "\(reporte!.altitud!.floatValue)" as AnyObject,
            "danoid": "\(reporte!.dano!.id.intValue)" as AnyObject,
            "tipoid": "\(reporte!.tipoEmergencia!.id.intValue)" as AnyObject,
            "descripcion": "\(reporte!.descripcion!)" as AnyObject,
            //"transito": "\(reporte!.transitabilidad!.id.integerValue)",transitabilidadFinal
            "transito": transitabilidadFinal as AnyObject,
            "categoriaid": "\(categoriaId)" as AnyObject,
            "vehiculostransitanautos": "\(todoTipoAuto)" as AnyObject,
            "vehiculostransitancamiones": "\(todoTipoCamiones)" as AnyObject,
            "vehiculostransitantodotipo": "\(todoTipoVehiculo)" as AnyObject,
            "fechacreacionupdate": "\(reporte!.fechaCreacion!)" as AnyObject,
            "fechaprovisional": fechaProvisional as AnyObject,
            "fechadefinitiva": fechaDefinitiva as AnyObject,
            "entidadfederativaid": (reporte!.entidadFederativa?.id)! as AnyObject,
            "rutaalternativa": reporte?.rutaAlterna  as AnyObject,
            "accionesrealizadas": "\(reporte!.accionesRealizadas!)"  as AnyObject,
            "activo": "1"  as AnyObject,
            "emergencia": "\(0)" as AnyObject,
            "croquisimagenid" : responseString as AnyObject
            
        ]
        
        /*
         NSDictionary *dictionaryCroquisEmergencia = @{
         @"emergenciaid":ICVEEMERGENCIASERVER (CHECK)
         ,@"accionesrealizadas":EMERGENCIA.accionesRealizadas (CHECK)
         ,@"activo":@"1" (CHECK)
         ,@"altitud":[EMERGENCIA.altitud stringValue] (CHECK)
         //,@"categoriaid":[EMERGENCIA.icveCategoriaEmergencia stringValue] (CHECK)
         ,@"danoid":[EMERGENCIA.icveDanos stringValue] (CHECK)
         ,@"descripcion":EMERGENCIA.descripcion (CHECK)
         //,@"fechacreacion":@"1401245901000"
         ,@"fechadefinitiva":EMERGENCIA.fechaDefinitiva (CHECK)
         //,@"fechamodificacion":@"1401245901000"
         ,@"fechaprovisional":EMERGENCIA.fechaProvisional (CHECK)
         ,@"kmfinal":EMERGENCIA.kmFinal (CHECK)
         ,@"kminicial":EMERGENCIA.kmInicial (CHECK)
         ,@"latitud":[EMERGENCIA.latitud stringValue] (CHECK)
         //,@"libroblanco":@""
         ,@"longitud":[EMERGENCIA.longitud stringValue]
         //,@"recursos":@""
         //,@"rutaalternativa":[EMERGENCIA.rutaAlternativa stringValue]
         ,@"subtramoid":[EMERGENCIA.icveSubtramo stringValue] (NOCHECK)
         ,@"tipoid":[EMERGENCIA.icveTipoEmergencia stringValue] (CHECK)
         ,@"transito":[EMERGENCIA.icveTransito stringValue]  (CHECK)
         //,@"usuarioid":@""
         ,@"vehiculostransitanautos":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"vehiculostransitancamiones":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"vehiculostransitantodotipo":[EMERGENCIA.tipoVehiculo stringValue]
         ,@"croquisimagenid":ICVEIMAGENSERVER
         };*/
        
        
        
        
        
        print("Emergencia Croquis Info  Create  \(conceptDict)")
        
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: conceptDict, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data": JSON] as Parameters
        
        
        
        Alamofire.request("\(URL_SERVICES)\(SERVICIO_URL_EMERGENCIA_CROQUIS_CREATE)", method : .post,parameters: data)
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Accion Create ERROR: \(error.localizedDescription)")
                    
                }else{
                    
                    print("Response JSON: \(response.result.value!)")
                    
                }
                
        }
        
        
    }
    
    
    
    
    class func sendConceptosImagenInfo(id : Int , responseString : Int){
        let conceptoIDValidate =  id
        
        //print("Response JSON: \(response.result.value!)")
        
        
        let imagenID: [String: AnyObject] = [
            "imagenid" : responseString as AnyObject
        ]
        let actividadesID: [String: AnyObject] = [
            "actividadid" : conceptoIDValidate as AnyObject
        ]
        
        
        let conceptDict: [String: AnyObject] = [
            "actividades" : actividadesID as AnyObject
            ,"imagen" : imagenID as AnyObject
        ]
        
        /*
         NSDictionary *dictionaryImagenConcepto = @{//@"emergenciaimagenid":@"-1"
         @"actividades":@{@"actividadid":ICVECONCEPTO}
         ,@"imagen":@{@"imagenid":ICVEIMAGEN}
         };*/
        
        
        
        print("Concepto imagen Create  \(conceptDict)")
        
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: conceptDict, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data": JSON] as Parameters
        
        
        
        Alamofire.request("\(URL_SERVICES)\(SERVICIO_CONCEPTO_IMAGEN_CREATE)", method: .post, parameters: data)
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Accion Create Accion Image ERROR: \(error.localizedDescription)")
                    
                }else{
                    
                    print("Response Accion Image JSON: \(response.result.value!)")
                    
                }
                
        }
    }
    
    
    
    class func createImageRequest(type : String , id : Int , image : Imagen ,reporte : Reporte?){
        // With NSURLSession
        let request = NSMutableURLRequest(url: NSURL(string: "\(URL_REPORTES)\(SERVICIO_IMAGE_CREATE)")! as URL)
        
        // Set Request
        let boundary = "0xKhTmLbOuNdArY"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.timeoutInterval = 300
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpShouldHandleCookies = false
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Set Body
        let body = NSMutableData()
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Disposition: form-data; name=\"filesToUpload\"; filename=\"FotoEmergencia.jpeg\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: multipart/form-data\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSData(data: image.file) as Data)
        //print("Image Data: \(image.file)")
        body.append(NSString(format: "\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "--%@--\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        
        // Set Some values of Request
        request.httpBody = body as Data
        request.setValue("\(body.length)", forHTTPHeaderField: "Content-Length")
        
        
        // Start Connection
        SVProgressHUD.show(withStatus: "Enviando imagene(s)...")
        let task =  URLSession.shared.dataTask(with: request as URLRequest,
                                                                     completionHandler: { (data, response, error) -> Void in
                                                                        
                                                                        // Hide Progress HUD
                                                                        //dispatch_async(dispatch_get_main_queue(),{
                                                                            SVProgressHUD.dismiss()
                                                                       // });
                                                                        
                                                                        
                                                                        
                                                                        
                                                                        if let dataValueResponse = data {
                                                                            
                                                                            // You can print out response object
                                                                            print("******* response = \(response)")
                                                                            
                                                                            
                                                                            
                                                                            do {
                                                                                guard let data = data else {
                                                                                    throw JSONError.NoData
                                                                                }
                                                                                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                                                                                    throw JSONError.ConversionFailed
                                                                                }
                                                                                print(json)
                                                                                
                                                                                let succesvalue = json.object(forKey: "success");
                                                                                
                                                                                if((succesvalue as! NSNumber) == 1){
                                                                                    
                                                                                    
                                                                                    let dataValue = json.object(forKey: "data");
                                                                                    print("Datta Value: \(dataValue!)")
                                                                                    
                                                                                    let imagenid = (                                                                                        dataValue as AnyObject).objectAt(0).object(forKey :"imagenid");
                                                                                    
                                                                                    
                                                                                    
                                                                                    
                                                                                    print("Imagen ID: \(imagenid)")
                                                                                    
                                                                                    image.id = imagenid as! Int as NSNumber
                                                                                    
                                                                                    // Save
                                                                                    do {
                                                                                        try image.managedObjectContext?.save()
                                                                                        
                                                                                    } catch {
                                                                                        fatalError("Failure to save context in accion id, with error: \(error)")
                                                                                    }
                                                                                    
                                                                                    switch type{
                                                                                    case TYPE_IMAGE_REPORT:
                                                                                        sendEmergenciaImagenInfo(id: id , responseString: imagenid as! Int)
                                                                                    case TYPE_IMAGE_CONCEPT:
                                                                                        sendConceptosImagenInfo(id: id , responseString: imagenid as! Int)
                                                                                    case TYPE_IMAGE_CROQUIS:
                                                                                        sendEmergenciaCroquisInfo(id: id , responseString: imagenid as! Int, reporte: reporte)
                                                                                    default:
                                                                                        print("Se entro en el case default type IMAGE")
                                                                                        
                                                                                    }
                                                                                    
                                                                                    
                                                                                }
                                                                                
                                                                            } catch let error as JSONError {
                                                                                print(error.rawValue)
                                                                            } catch let error as NSError {
                                                                                print(error.debugDescription)
                                                                            }
                                                                            
                                                                            
                                                                            
                                                                            print(dataValueResponse.count)
                                                                            // you can use data here
                                                                            
                                                                            // Print out reponse body
                                                                            let responseString = NSString(data: dataValueResponse, encoding: String.Encoding.utf8.rawValue)
                                                                            print("****** response String = \(responseString!)")
                                                                            
                                                                            /*
                                                                             let json =  try!NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSDictionary
                                                                             
                                                                             print("json value \(json)")
                                                                             
                                                                             //var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err)
                                                                             */
                                                                            
                                                                            // MARK
                                                                            // TODO, GUARDAR EL ID DE LA IMAGEN Y MANDAR A LLAMAR sendEmergenciaImagenInfo para guardar el ID DE LA IMAGEN Y SU EMERGENCIA RELACIONADA
                                                                            
                                                                        } else if let error = error {
                                                                            print("******* response Error = \(error.localizedDescription)")
                                                                        }
        })
        task.resume()
        
    }
    
    class func getReporteE7(id : Int){
        let imagenID: [String: AnyObject] = [
            "idEmergencia" : id as AnyObject
        ]
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: imagenID, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data1": JSON] as Parameters
        
        
        Alamofire.request("\(URL_SERVICES)\(SERVICIO_VER_E7)", method: .post, parameters: data)
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Accion Create Accion Image ERROR: \(error.localizedDescription)")
                    
                    
                }else{
                    
                    print("Response Accion Image JSON: \(response.result.value!)")
                    onResponseApiListenerDelegate.onReporteHistoricoFetchFinished(responseHistorico: response.result.value as AnyObject)
                    
                }
                
        }
    }
    
    
    class func getReporteHistorico(id : Int){
        
        let imagenID: [String: AnyObject] = [
            "idEmergencia" : id as AnyObject
        ]
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: imagenID, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data1": JSON] as Parameters
       /* Alamofire.request( "\(URL_SERVICES)\(SERVICIO_VER_HISTORICO)", method:.post, parameters: data)
            .responseJSON { response in*/
                
        print("data reporte historico \(URL_SERVICES)\(SERVICIO_VER_HISTORICO)\(data)")
        Alamofire.request( "\(URL_SERVICES)\(SERVICIO_VER_HISTORICO)", method: .post ,parameters: data)
            .responseJSON { response  in
                print("eroro alamofire \(response.result)")
                if let error = response.result.error {
                    print("Accion Create Accion Image ERROR: \(error.localizedDescription)")
                     onResponseApiListenerDelegate.onReporteHistoricoFetchFinished(responseHistorico: response.result.value as AnyObject)
                }else{
                    
                    print("Response Accion Image JSON: \(response.result.value!)")
                    onResponseApiListenerDelegate.onReporteHistoricoFetchFinished(responseHistorico: response.result.value as AnyObject)
                }
                
        }
        
    }
    
    
    
    
    class func getImagenesEmergencia(id : Int){
        
        let imagenID: [String: AnyObject] = [
            "idEmergencia" : id as AnyObject
        ]
        
        var JSON: NSString!
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: imagenID, options: [])
            JSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("json error: \(error)")
        }
        
        let data = ["data1": JSON] as Parameters
        
        
        Alamofire.request( "\(URL_SERVICES)\(SERVICIO_VER_IMAGENES)", method : .post, parameters: data)
            .responseJSON { response in
                
                if let error = response.result.error {
                    
                    print("Accion Create Accion Image ERROR: \(error.localizedDescription)")
                    onResponseApiListenerDelegate.onImageEmergenciasFetchFinished(responseImagenes: response.result.value as AnyObject)
                }else{
                    
                    print("Response Accion Image JSON: \(response.result.value!)")
                    onResponseApiListenerDelegate.onImageEmergenciasFetchFinished(responseImagenes: response.result.value as AnyObject)
                }
                
        }
        
    }
  }

