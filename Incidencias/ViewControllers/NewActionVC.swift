//
//  PopUpActionsVC.swift
//  Incidencias
//
//  Created by Sebastian on 11/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData

class NewActionVC: UIViewController , UIPopoverPresentationControllerDelegate {
    
    
    
    // MARK: IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var transitabilidadButton: UIButton!
    
    
    // UISwitch
    @IBOutlet weak var autoSwitch: UISwitch!
    @IBOutlet weak var camionesSwitch: UISwitch!
    @IBOutlet weak var todoTipoSwitch: UISwitch!

    var currentButton: UIButton!

    let transitabilidadDict = [0: "Provisional", 1: "Parcial", 2: "Total", 3: "Nulo"]
    var transitabilidadesArray = [Transitabilidad]()
    var reporte: Reporte?

    
    // MARK: - Variables
    var currentCatalogTitle: String!
    var selectedTransitabilidad: Transitabilidad?

    
    // Get Core Data Manager Context
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.borderWidth = CGFloat(1)
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.backgroundColor = UIColor.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewActionVC.actionTapContentView))

        
        contentView.addGestureRecognizer(tapGesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Public Methods
    
    func actionTapContentView(){
        self.view.endEditing(true)
    }
    
    // MARK: IBActions
    @IBAction func actionButtonCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionButtonCatalog(_ button: UIButton){
        
        var object = [NSManagedObject]()

        // El comentario para 
        

            // Case of "Transitabilidad"
 
        
        // Get Catalog "Transitabilidad"
        if let transitabilidades = HandlerIO.getEntityStorage("Transitabilidad") as? [Transitabilidad]{
            if transitabilidades.isEmpty{
                print("Transitabilidades is Empty")
                
                // Save Catalog "Transitabilidad"
                for (id, nombre) in transitabilidadDict{
                    
                    // Create new Transitabilidad
                    let description = NSEntityDescription.entity(forEntityName: "Transitabilidad", in: self.managedObjectContext)!
                    let transitabilidad = Transitabilidad(entity: description, insertInto: self.managedObjectContext)
                    
                    // Set Attributes
                    transitabilidad.id = id as NSNumber
                    transitabilidad.nombre = nombre
                }
                
                // Save
                do {
                    try self.managedObjectContext.save()
                    //self.getCatalogs()
                } catch {
                    fatalError("Failure to save context in Transitabilidad with error: \(error)")
                }
            }else{
                print("# Transitabilidad in storage: \(transitabilidades.count)")
                transitabilidadesArray = transitabilidades
                
                currentCatalogTitle = "Transitabilidad"
                currentButton = transitabilidadButton
                object = transitabilidadesArray


            }

        }

        self.performSegue(withIdentifier: "ShowPopoverActions", sender: object)

        //Comentario
        // Show Popover
        //Default Swift
            

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // Set Catalog Popover Controller
        if segue.identifier == "ShowPopoverActions" {
            let catalogController = segue.destination as! CatalogPopoverController
            
            // Set Controller
            catalogController.segueType = .push
            catalogController.catalog = sender as! [NSManagedObject]
            catalogController.title = currentCatalogTitle
            
            
            // Set Date Picker Popover Controller
        }
    }

    
    @IBAction func actionGuardarAccion(_ button: UIButton){
        

        //Guardamos la accion relacionada a un reporte
        saveAccion()
        
        //Hacemos dismiss del View Controller
        self.dismiss(animated: true, completion: nil)

        
        
    }
    
    
    func saveAccion(){
        
        var message = ""

        // 1. "Datos de Ubicación"
        if descriptionTextView.text!.isEmpty {
            message += "descripcion \n"
        }
        if selectedTransitabilidad == nil{
            message += "Transitabilidad \n"
        }
        
        // Save or show alert to validate
        if message.isEmpty{
        
            // Create new Transitabilidad
            let accionEntity = NSEntityDescription.entity(forEntityName: "Accion", in: self.managedObjectContext)!
            let accion = Accion(entity: accionEntity, insertInto: self.managedObjectContext)
            
            accion.descripcion = descriptionTextView.text!
            
            accion.transito =  selectedTransitabilidad?.nombre
            
            
            accion.reporte = reporte
            
            // Save "Tipo de vehiculos que pueden transitar":
            var tipoVehiculo: String?
            if todoTipoSwitch.isOn{
                tipoVehiculo = "Todo tipo"
            }else if camionesSwitch.isOn{
                tipoVehiculo = "Camiones"
            }else if autoSwitch.isOn{
                tipoVehiculo = "Autos"
            }
            accion.tipoVehiculo = tipoVehiculo
            
            //4
            // Set Attributes
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyyHHmmssSS"
            let id: Int64 = Int64(dateFormatter.string(from: Date()))!
            accion.id = NSNumber(value: id as Int64)
            reporte?.hasBeedModified = true
            
            do{
                try managedObjectContext.save()
                
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo))")
                
            }
            
            
            do{
                try reporte!.managedObjectContext?.save()
                
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo))")
                
            }
            
        }
        
        else{
            // Alert Controller
            let alert = UIAlertController(title: "Datos faltantes", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        // Set Attributes
        //accion.icveEmergencia =
        //accion.description = nombre
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
        
    }

    
    @IBAction func unwindPopWithSelectedItem(_ segue: UIStoryboardSegue){
        
        // Get Item Selected
        if let catalogController = segue.source as? CatalogPopoverController {
            
            if let object = catalogController.selectedObject as? Transitabilidad{
                
                
                selectedTransitabilidad = object
                transitabilidadButton.setTitle(selectedTransitabilidad?.nombre, for: UIControlState())

                
                switch selectedTransitabilidad!.nombre {
                    
                case "Provisional":
                    
                    // Enable all Switch
                    autoSwitch.isUserInteractionEnabled = true
                    camionesSwitch.isUserInteractionEnabled = true
                    todoTipoSwitch.isUserInteractionEnabled = true
                    
                    // If anything is ON put "Todo tipo" en ON
                    if !(autoSwitch.isOn || camionesSwitch.isOn || todoTipoSwitch.isOn){
                        todoTipoSwitch.setOn(true, animated: true)
                    }
                    
                case "Parcial":
                    
                    // Disable and turn OFF "Todo tipo"
                    todoTipoSwitch.setOn(false, animated: true)
                    todoTipoSwitch.isUserInteractionEnabled = false
                    
                    // If anything is ON put "Autos" en ON
                    if !(autoSwitch.isOn || camionesSwitch.isOn){
                        autoSwitch.setOn(true, animated: true)
                    }
                    
                case "Total":
                    
                    // Disable and turn OFF "Autos" and "Camiones"
                    autoSwitch.setOn(false, animated: true)
                    camionesSwitch.setOn(false, animated: true)
                    autoSwitch.isUserInteractionEnabled = false
                    camionesSwitch.isUserInteractionEnabled = false
                    
                    // Disable and turn ON "Todo tipo"
                    todoTipoSwitch.setOn(true, animated: true)
                    todoTipoSwitch.isUserInteractionEnabled = false
                    
                case "Nulo":
                    
                    // Disable and turn OFF all
                    autoSwitch.setOn(false, animated: true)
                    camionesSwitch.setOn(false, animated: true)
                    todoTipoSwitch.setOn(false, animated: true)
                    autoSwitch.isUserInteractionEnabled = false
                    camionesSwitch.isUserInteractionEnabled = false
                    todoTipoSwitch.isUserInteractionEnabled = false
                    
                default:
                    print("Is any other Transitabilidad")
                }


            }
            
            // Set values

        }
    }
    
    
    
    
    @IBAction func actionSwitchesTransitabilidad(_ sender: UISwitch) {
        
        if let transitabiliad = selectedTransitabilidad{
            
            switch sender{
                
            case autoSwitch:
                
                if autoSwitch.isOn{
                    camionesSwitch.setOn(false, animated: true)
                    todoTipoSwitch.setOn(false, animated: true)
                }
                else{
                    if transitabiliad.nombre == "Provisional" || transitabiliad.nombre == "Parcial"{
                        Utilities.showSimpleAlertControllerMessage("Para Transitabilidad \(transitabiliad.nombre) se debe seleccionar al menos un tipo de transito", inController: self)
                        autoSwitch.setOn(true, animated: true)
                    }
                }
                
            case camionesSwitch:
                
                if camionesSwitch.isOn{
                    autoSwitch.setOn(false, animated: true)
                    todoTipoSwitch.setOn(false, animated: true)
                }
                else{
                    if transitabiliad.nombre == "Provisional" || transitabiliad.nombre == "Parcial"{
                        Utilities.showSimpleAlertControllerMessage("Para Transitabilidad \(transitabiliad.nombre) se debe seleccionar al menos un tipo de transito", inController: self)
                        camionesSwitch.setOn(true, animated: true)
                    }
                }
                
            case todoTipoSwitch:
                
                if todoTipoSwitch.isOn{
                    autoSwitch.setOn(false, animated: true)
                    camionesSwitch.setOn(false, animated: true)
                }
                else{
                    if selectedTransitabilidad!.nombre == "Provisional"{
                        Utilities.showSimpleAlertControllerMessage("Para Transitabilidad \(transitabiliad.nombre) se debe seleccionar al menos un tipo de transito", inController: self)
                        todoTipoSwitch.setOn(true, animated: true)
                    }
                }
                
            default:
                print("Is any other selected switch")
            }
        }
        else{
            Utilities.showSimpleAlertControllerMessage("Debes seleccionar primero Transitabilidad", inController: self)
            sender.setOn(false, animated: true)
        }
    }
    
    

}
