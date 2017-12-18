//
//  HandlerIO.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 16/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// HardCode Values:
let USER = "usuario"
let PASSWORD = "password"
//let HOST = "192.168.0.124:82"
let HOST = "187.188.120.133:80"
//let HOST = "192.168.0.102"

//let HOST = "10.0.0.14"
//let HOST = "192.168.2.4"



// MARK: Key Constants
let KEY_USER = "user"
let KEY_PASSWORD = "password"
let KEY_HOST = "host"

// User Defaults
let userDefaults = UserDefaults.standard

// Get Core Data Manager Context
let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext


class HandlerIO {
    
    class func saveUser(_ user: String, password: String){
        userDefaults.setValue(user, forKey: KEY_USER)
        userDefaults.setValue(password, forKey: KEY_PASSWORD)
    }
    
    class func isRegisteredUser() -> Bool{
        if let _ = userDefaults.value(forKey: KEY_USER){
             return true
        }
        return false
    }
    
    class func isUserDataCorrect(_ user: String, password: String) -> Bool {
        if user == USER && password == PASSWORD{
            return true
        }
        else if (userDefaults.string(forKey: KEY_USER) == user && userDefaults.string(forKey: KEY_PASSWORD) == password){
            return true
        }
        return false
    }
    class func saveHostServices(_ Host: String, view:UIViewController){
        if Host != ""{
            userDefaults.setValue("\(Host)", forKey: KEY_HOST)
        }else{
            userDefaults.setValue("\(HOST)", forKey: KEY_HOST)
        }
        showSimpleAlert("Aviso", message: "Se Actualizo Correctamente\nel Host de Servicios", viewController: view)
        
    }
    class func getHostServices()->String{
        if userDefaults.string(forKey: KEY_HOST) != nil{
            return userDefaults.string(forKey: KEY_HOST)!
        }else{
            return "\(HOST)"
        }
        
    }
    class func saveFilters(_ data:[String]) {
        userDefaults.setValue(data, forKey: "filters")
    }
    class func getFilters() -> [String]{
        if userDefaults.value(forKey: "filters") != nil{
            return userDefaults.value(forKey: "filters") as! [String]
        }else{
            let datos = [String](repeating: "", count: 4)
            return datos
        }
    }
    class func saveFiltersBool(_ data:Bool) {
        userDefaults.setValue(data, forKey: "isUpdate")
    }
    class func getFiltersBool()->Bool{
        if userDefaults.string(forKey: "isUpdate") != nil{
            return (userDefaults.value(forKey: "isUpdate") as? Bool!)!
        }else{
            return true
        }
        
    }

    class func showSimpleAlert(_ title: String, message: String, viewController:UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    class func getReports() -> [Reporte]?{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reporte");
        do{
            let objects = try managedObjectContext.fetch(fetchRequest) as! [Reporte]
            return objects
        } catch {
            print("Fetch failed in Reort, with error: \(error)")
        }
        
        return nil
    }
    
    class func getEntityStorage(_ name: String) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        var sortDescriptor : NSSortDescriptor
        
        if name == "EntidadFederativa"{
            
            sortDescriptor = NSSortDescriptor(key: "nombre", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }

        
        do{
            let objects = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            return objects
        } catch {
            print("Fetch failed in \(name), with error: \(error)")
        }
        
        return nil
    }
}
