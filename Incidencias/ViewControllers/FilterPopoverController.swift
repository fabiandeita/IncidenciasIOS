//
//  FilterVC.swift
//  Incidencias
//
//  Created by Sebastian TC on 11/2/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData

class FilterPopoverController: UIViewController{

    // MARK: - IBOutlets
    // Buttons
    @IBOutlet weak var entidadButton: UIButton!
    @IBOutlet weak var carreteraButton: UIButton!
    @IBOutlet weak var tramoButton: UIButton!
    @IBOutlet weak var subtramoButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    // MARK: - Variables
    var reports = [Reporte]()
    var currentCatalogTitle: String!
    var currentButton: UIButton!
    var arrayData = [String](repeating: "", count: 4)
    var isUpdateView: Bool = true
    
    
    // MARK: - Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    var entidadesArray = [EntidadFederativa]()
    var carreterasArray = [Carretera]()
    var tramosArray = [Tramo]()
    var subtramosArray = [Subtramo]()
    var selectedEntidad: EntidadFederativa?
    var selectedCarretera: Carretera?
    var selectedTramo: Tramo?
    var selectedSubtramo: Subtramo?
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get Local Catalogs
        print("Cargando la vista de filtros")
        getCatalogs()
        setDataFilter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func getCatalogs(){
        
        // Validate if Catalog "Entidades Federativas" is Storage
        if let entidades = HandlerIO.getEntityStorage("EntidadFederativa") as? [EntidadFederativa] {
            if entidades.isEmpty {
                print("Entidades Federativas is Empty")
            }else{
                print("# Entidades Federativas in storage: \(entidades.count)")
                entidadesArray = entidades
                
                // Validate if Catalog "Carreteras" is Storage
                if let carreteras = HandlerIO.getEntityStorage("Carretera") as? [Carretera] {
                    if carreteras.isEmpty{
                        print("Carreteras is Empty")
                    }else{
                        print("# Carreteras in storage: \(carreteras.count)")
                        
                        // Validate if catalog "Tramos" is Storage
                        if let tramos = HandlerIO.getEntityStorage("Tramo") as? [Tramo] {
                            if tramos.isEmpty{
                                print("Tramos is Empty")
                            }else{
                                print("# Tramos in storage: \(tramos.count)")
                                
                                // Validate if catalog "Subtramos" is Storage
                                if let subtramos = HandlerIO.getEntityStorage("Subtramo") as? [Subtramo] {
                                    if subtramos.isEmpty{
                                        print("Subtramos is Empty")
                                    }else{
                                        print("# Subtramos in storage: \(subtramos.count)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

   
    func setDataFilter() {
        var filterData = HandlerIO.getFilters()
        if filterData[0] != ""{
            setObject(0, str: filterData[0])
            if filterData[1] != ""{
                setObject(1, str: filterData[1])
                if filterData[2] != ""{
                    setObject(2, str: filterData[2])
                    if filterData[3] != ""{
                        setObject(3, str: filterData[3])
                    }
                }
            }
        }
        //entidadButton.setTitle(selectedEntidad?.nombre, forState: .Normal)
    }
    func setObject(_ position:Int,str:String){
        switch position {
        case 0:
            for entidad in entidadesArray{
                if str == entidad.nombre!{
                    selectedEntidad = entidad
                }
            }
            carreterasArray = selectedEntidad?.carreteras?.allObjects as! [Carretera]
            entidadButton.setTitle(selectedEntidad?.nombre, for: UIControlState())
            arrayData.remove(at: 0)
            arrayData.insert(selectedEntidad!.nombre, at: 0)
            break
        case 1:
            for entidad in carreterasArray{
                if str == entidad.nombre{
                    selectedCarretera = entidad
                }
            }
            tramosArray = selectedCarretera?.tramos?.allObjects as! [Tramo]
            carreteraButton.setTitle(selectedCarretera?.nombre, for: UIControlState())
            arrayData.remove(at: 1)
            arrayData.insert(selectedCarretera!.nombre, at: 1)
            break
        case 2:
            for entidad in tramosArray{
                if str == entidad.nombre{
                    selectedTramo = entidad
                }
            }
            tramoButton.setTitle(selectedTramo?.nombre, for: UIControlState())
            arrayData.remove(at: 2)
            arrayData.insert(selectedTramo!.nombre, at: 2)
            subtramosArray = selectedTramo?.subtramos.allObjects as! [Subtramo]
            break
        case 3:
            for entidad in subtramosArray{
                if str == entidad.nombre{
                    selectedSubtramo = entidad
                }
            }
            arrayData.remove(at: 3)
            arrayData.insert(selectedSubtramo!.nombre, at: 3)
            subtramoButton.setTitle(selectedSubtramo?.nombre, for: UIControlState())
            break
            
        default:
            break
        }
    }
    // MARK: - IBActions
    
    @IBAction func actionButtonCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionButtonClearFilter(_ sender: AnyObject) {
        
        arrayData = [String](repeating: "", count: 4)
        HandlerIO.saveFilters(arrayData)
        selectedEntidad = nil
        entidadButton.setTitle(defaultButtonTitle, for: UIControlState())
        carreterasArray.removeAll()
        selectedCarretera = nil
        carreteraButton.setTitle(defaultButtonTitle, for: UIControlState())
        tramosArray.removeAll()
        selectedTramo = nil
        tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
        selectedSubtramo = nil
        subtramosArray.removeAll()
        subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
    }
    
    @IBAction func actionButtonCatalog(_ button: UIButton){
        
        var object = [NSManagedObject]()
        
        // Set Catalog Title
        switch button{
            
            // Cases of "Datos de Ubicación"
        case entidadButton:
            
            if entidadesArray.isEmpty{
                Utilities.showAlertWhenLackCatalogsInController(self)
                return
            }
            
            currentCatalogTitle = "Entidades"
            currentButton = entidadButton
            object = entidadesArray
            
        case carreteraButton:
            print("Selected Button")
            
            if selectedEntidad == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Entidad", inController: self)
                return
            }
            
            currentCatalogTitle = "Carreteras"
            currentButton = carreteraButton
            object = carreterasArray
            
        case tramoButton:
            
            if selectedCarretera == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Carretera", inController: self)
                return
            }
            
            currentCatalogTitle = "Tramos"
            currentButton = tramoButton
            object = tramosArray
            
        case subtramoButton:
            
            if selectedCarretera == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Tramo", inController: self)
                return
            }
            
            currentCatalogTitle = "Subtramos"
            currentButton = subtramoButton
            object = subtramosArray
        
        default:
            print("Selected any other button that is not Catalog")
        }
        
        // Show Popover
        self.performSegue(withIdentifier: "ShowCatalogFromFilter", sender: object)
    }
    
    @IBAction func actionAceptar(_ sender: UIButton) {
        if HandlerIO.getFiltersBool(){
            self.performSegue(withIdentifier: "updateFilter", sender: self)
        }else{
            self.performSegue(withIdentifier: "configFilter", sender: self)
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set Controller to show Catalog Controller
        if let catalogController = segue.destination as? CatalogPopoverController{
            catalogController.segueType = .push
            catalogController.catalog = sender as! [NSManagedObject]
            catalogController.title = currentCatalogTitle
        }
        else if let updateTableVC = segue.destination as? UpdateTableVC{
            HandlerIO.saveFilters(arrayData)
            updateTableVC.datosFilter = arrayData
            
        }else if let configTableVC = segue.destination as? ConfigurationTableVC{
            HandlerIO.saveFilters(arrayData)
            configTableVC.datosFilter = arrayData
            
        }
    }
    
    @IBAction func unwindPopWithSelectedItem(_ segue: UIStoryboardSegue){
        
        // Get Item Selected
        if let catalogController = segue.source as? CatalogPopoverController {
            //print("Item Selected: \(catalogController.selectedItem)")
            
            // Set values
            if let object = catalogController.selectedObject as? EntidadFederativa {
                
                if object != selectedEntidad {
                    
                    selectedEntidad = object
                    carreterasArray = selectedEntidad?.carreteras?.allObjects as! [Carretera]
                    entidadButton.setTitle(selectedEntidad?.nombre, for: UIControlState())
                    arrayData.remove(at: 0)
                    arrayData.insert(selectedEntidad!.nombre, at: 0)
                    
                    // Set Other Default Values in Cascade
                    selectedCarretera = nil
                    carreteraButton.setTitle(defaultButtonTitle, for: UIControlState())
                    tramosArray.removeAll()
                    selectedTramo = nil
                    tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedSubtramo = nil
                    subtramosArray.removeAll()
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
            }
            else if let object = catalogController.selectedObject as? Carretera {
                
                if object != selectedCarretera{
                    
                    selectedCarretera = object
                    tramosArray = selectedCarretera?.tramos?.allObjects as! [Tramo]
                    carreteraButton.setTitle(selectedCarretera?.nombre, for: UIControlState())
                    arrayData.remove(at: 1)
                    arrayData.insert(selectedCarretera!.nombre, at: 1)
                    
                    // Set Other Default Values in Cascade
                    selectedTramo = nil
                    tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedSubtramo = nil
                    subtramosArray.removeAll()
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
            }
            else if let object = catalogController.selectedObject as? Tramo {
                
                if object != selectedTramo {
                    
                    selectedTramo = object
                    tramoButton.setTitle(selectedTramo?.nombre, for: UIControlState())
                    arrayData.remove(at: 2)
                    arrayData.insert(selectedTramo!.nombre, at: 2)
                    subtramosArray = selectedTramo?.subtramos.allObjects as! [Subtramo]
                    
                    // Set Other Default Values in Cascade
                    selectedSubtramo = nil
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
            }
            else if let object = catalogController.selectedObject as? Subtramo {
                selectedSubtramo = object
                arrayData.remove(at: 3)
                arrayData.insert(selectedSubtramo!.nombre, at: 3)
                subtramoButton.setTitle(selectedSubtramo?.nombre, for: UIControlState())
            }
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension FilterPopoverController: UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}


