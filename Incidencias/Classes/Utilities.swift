//
//  Utilities.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 01/12/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import Foundation
import UIKit

enum CatalogSegueType{
    case popover
    case push
    case none
    case popoverReport
    case popoverSign
}

class Utilities {
    
    class func showAlertWhenLackCatalogsInController(_ controller: UIViewController){
        
        let alertController = UIAlertController(title: "Sin Catálogos", message: "Ir a Config. para descargar catálogos.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertWhenMultipleEntitiesSelectedInController(controller: UIViewController){
        
        let alertController = UIAlertController(title: "Multiples Entidades", message: "Solo selecciona una entidad para poder seleccionar carretera.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
    class func showSimpleAlertControllerMessage(_ message: String, inController controller: UIViewController){
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        controller.present(alertController, animated: true, completion: nil)
    }
        class func fechaString(timeIs:Double)->String{
        
        if let theDate = Date(jsonDate: "/Date(\(timeIs))/") {
            let dateFormatterService = DateFormatter()
            dateFormatterService.dateFormat = "yyyy-MM-dd"//"M/d/yyyy h:mm:ss a"
            

            return dateFormatterService.string(from: theDate)
        } else {
            return "N/A"
        }
        
    }
    
}
