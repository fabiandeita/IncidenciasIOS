//
//  UpdateSelectionReportViewCell.swift
//  Incidencias
//
//  Created by Sebastian on 10/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData

protocol selectFilter {
    func filterwithButton(_ object:[NSManagedObject])
}

class UpdateSelectionReportViewCell: UITableViewCell {

    @IBOutlet weak var entidadButton: UIButton!
    @IBOutlet weak var carreteraButton: UIButton!
    @IBOutlet weak var tramoButton: UIButton!
    @IBOutlet weak var subTramoButton: UIButton!
    @IBOutlet weak var limpiarButton: UIButton!
    
    // MARK: - Variables
    var reports = [Reporte]()
    var currentCatalogTitle: String!
    var currentButton: UIButton!
    var arrayData = [String](repeating: "", count: 4)
    var view : UIViewController!
    
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
    
    
    var filterDelegate : selectFilter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(){
        getCatalogs()
        setDataFilter()
    }
    
    
    @IBAction func actionFilter(_ sender: UIButton) {
        
        setData()
        
        var object2 = [NSManagedObject]()
        
        // Set Catalog Title
        switch sender{
            
        // Cases of "Datos de Ubicación"
        case entidadButton:
            
            if entidadesArray.isEmpty{
                Utilities.showAlertWhenLackCatalogsInController(view)
                return
            }
            
            currentCatalogTitle = "Entidades"
            currentButton = entidadButton
            object2 = entidadesArray
            
        case carreteraButton:
            print("Selected Button")
            
            if selectedEntidad == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Entidad", inController: view)
                return
            }
            
            currentCatalogTitle = "Carreteras"
            currentButton = carreteraButton
            object2 = carreterasArray
            
        case tramoButton:
            
            if selectedCarretera == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Carretera", inController: view)
                return
            }
            
            currentCatalogTitle = "Tramos"
            currentButton = tramoButton
            object2 = tramosArray
            
        case subTramoButton:
            
            if selectedCarretera == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Tramo", inController: view)
                return
            }
            
            currentCatalogTitle = "Subtramos"
            currentButton = subTramoButton
            object2 = subtramosArray
            
        default:
            print("Selected any other button that is not Catalog")
        }
        
        filterDelegate.filterwithButton(object2)
        
        /*var nameButton : String!
        switch sender {
        case entidadButton:
            nameButton = "entidad"
        case carreteraButton:
            nameButton = "carretara"
        case tramoButton:
            nameButton = "tramo"
        case subTramoButton:
            nameButton = "subtramo"
        default:
            nameButton = ""
        }
        filterDelegate.filterwithButton(nameButton)*/
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
            subTramoButton.setTitle(selectedSubtramo?.nombre, for: UIControlState())
            break
            
        default:
            break
        }
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
        subTramoButton.setTitle(defaultButtonTitle, for: UIControlState())
    }
    
    

}
