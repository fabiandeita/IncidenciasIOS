//
//  SignUpVC.swift
//  Incidencias
//
//  Created by Sebastian on 13/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import CoreData

class SignUpVC: UIViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, SelectItem {
    
    // MARK: IBOUtlets
    @IBOutlet var entidadButton: UIButton!
    @IBOutlet var dependenciaButton: UIButton!
    @IBOutlet var cargoButton: UIButton!
    
    
    @IBOutlet var nameUser: UITextField!
    @IBOutlet var apePatUser: UITextField!
    @IBOutlet var apeMatUser: UITextField!
    @IBOutlet var emailUser: UITextField!
    
    var currentCatalogTitle: String!
    var currentButton: UIButton!
    var connectionState: ConnectionState = .close
    var objetosEntidades2 :NSMutableArray = NSMutableArray()
    var objetosEntidadesDB2 :NSMutableArray = NSMutableArray()
    var dataEntidades2 :NSMutableArray = NSMutableArray()
    
    // MARK: Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    var entidadesArray = [EntidadFederativa]()
    var selectedEntidad: EntidadFederativa?
    var datosReport :NSMutableArray = NSMutableArray()
    
    var selectedDependencia : Int?
    
    var selectedCargo : Int?
    
    let newVC  = PopNewConceptViewController()


    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        newVC.itemSelectNewConceptDelegate = self

        getCatalogs()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Private Methods
    
    fileprivate func showSimpleAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    fileprivate func validateData() ->Bool{
        if nameUser.text == "" || apeMatUser.text == "" || apePatUser.text == "" || emailUser.text == "" || entidadButton.titleLabel?.text == "Seleccione"{
            return false
        }else{
            return true
        }
    
    }
    // MARK: get data
    //MARK: Data
    fileprivate func getCatalogs(){
        
        // ** STEPS DOWNLOAD CATALOGS ** //
        
        // ** GET CATALOGS OF "DATOS DE UBICACIÓN" ** //
        // Validate if Catalog "Entidades Federativas" is Storage
        if let entidades = HandlerIO.getEntityStorage("EntidadFederativa") as? [EntidadFederativa] {
            if entidades.isEmpty {
                print("Entidades Federativas is Empty")
                
                // 1. Download "Entidades Federativas"
                downloadCatalogEntidadesFederativas()
            }else{
                print("# Entidades Federativas in storage: \(entidades.count)")
                entidadesArray = entidades
                SVProgressHUD.dismiss()
                ///
            }
        }
    }
    
    fileprivate func showProgressWithStatus(_ string: String){
        if SVProgressHUD.isVisible() {
            SVProgressHUD.setStatus(string)
        }else{
            SVProgressHUD.show(withStatus: string)
        }
    }
    fileprivate func downloadCatalogEntidadesFederativas(){
        print("Downloading Catalog Entidades Federativas")
        showProgressWithStatus("Descargando Entidades...")
        
        connectionState = .downloadEntidades
        Alamofire.request("\(URL_SERVICES)\(SERVICIO_ENTIDADES)", method: .get)
            .responseJSON { response in
                
                if let error = response.result.error {
                    print("Download Entidades Federativas ERROR: \(error.localizedDescription)")
                    self.checkTaskRequestsAndDismissPorgress(error as NSError)
                    
                }else{
                    if let rootDict = response.result.value as? NSDictionary {
                        print("Download Entidades Federativas SUCCESS")
                        
                        // Array of "Entidades Federativas"
                        if let entidades = rootDict["data"] as? [NSDictionary] {
                            //print("Entidades Federativas: \(entidades)")
                            
                            // Save "Entidades Federativas" in DB
                            for entidad in entidades {
                                
                                // Create new Entidad Federativa
                                let description = NSEntityDescription.entity(forEntityName: "EntidadFederativa", in: self.managedObjectContext)!
                                let entidadFederativa = EntidadFederativa(entity: description, insertInto: self.managedObjectContext)
                                
                                // Set Attributes
                                entidadFederativa.clave = entidad["clave"] as! String
                                entidadFederativa.id = entidad["entidadid"] as! NSNumber
                                entidadFederativa.nombre = entidad["nombre"] as! String
                                
                                // Add to array
                                self.entidadesArray.append(entidadFederativa)
                            }
                            
                            // Save
                            do {
                                try self.managedObjectContext.save()
                                self.checkTaskRequestsAndDismissPorgress(nil)
                            } catch {
                                fatalError("Failure to save context in Entidades Federativas, with error: \(error)")
                            }
                        }
                    }
                }
        }
    }
    
    //MARK: Progress
    fileprivate func checkTaskRequestsAndDismissPorgress(_ error: NSError?){
        
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) -> Void in
            print("Tasks Running: \(tasks.count)")
            
            if tasks.isEmpty {
                
                switch self.connectionState{
                    
                case .downloadEntidades:
                    print("END Download all Entidades")
                    
                    if error == nil{
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.getCatalogs()
                        })
                        
                    }
                    else{
                        DispatchQueue.main.async(execute: { () -> Void in
                            SVProgressHUD.dismiss()
                        })
                    }
                default:
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                    })
                }
            }
        }
    }
    //MARK: buttons methods
    
    @IBAction func ActionCatalog(_ sender: UIButton) {
        
        var object = [NSManagedObject]()
        
        // Set Catalog Title
        switch sender{
            
            // Cases of "Datos de Ubicación"
        case entidadButton:
            
            if entidadesArray.isEmpty{
                Utilities.showAlertWhenLackCatalogsInController(self)
                return
            }
            
            currentCatalogTitle = "Entidades"
            currentButton = entidadButton
            object = entidadesArray
            self.performSegue(withIdentifier: "showPopOverSign", sender: object)

        case dependenciaButton:
            currentCatalogTitle = "Dependencia"
            currentButton = dependenciaButton
            newVC.title = "Dependencia"
            self.navigationController?.pushViewController(newVC, animated: true)
            object = entidadesArray
            
        case cargoButton:
            currentCatalogTitle = "Cargo"
            currentButton = cargoButton
            newVC.title = "Cargo"
            self.navigationController?.pushViewController(newVC, animated: true)
            object = entidadesArray
            
        default:
            print("Selected any other button that is not Catalog")
        }
        
        // Show Popover
        
    }
    func SendData(){
        let datosWSUSer :NSMutableDictionary = NSMutableDictionary()
        
        //print("\nDatos Report a mamndar \(datosReportDict)\n")
        datosWSUSer.setValue(nameUser.text!, forKey: "nombre")
        datosWSUSer.setValue(apePatUser.text!, forKey: "apellidoPaterno")
        datosWSUSer.setValue(apeMatUser.text!, forKey: "apellidoMaterno")
        datosWSUSer.setValue("\(emailUser.text!)@sct.gob.mx", forKey: "correoInstitucional")
        datosWSUSer.setValue("\(selectedEntidad?.value(forKey: "id") as! Int)", forKey: "entidadFederativa")
        datosWSUSer.setValue("\(selectedDependencia!)", forKey: "dependencia")
        datosWSUSer.setValue("\(selectedCargo!)", forKey: "cargo")


        sendWS("http://\(HandlerIO.getHostServices())/EmergenciasWS/web/Register_User.action", postRequest: datosWSUSer)
    }
    @IBAction func sendInfo(_ sender: UIButton) {
    
        if validateData(){
            print("Mandar servicios Web")
            SendData()
        }else{
            showSimpleAlert("Datos incorrectos", message: "Debes ingresar todos los datos del formulario")
        }
    }
    
    @IBAction func unwindWithSelectedItemSign(_ segue: UIStoryboardSegue){
        
        // Get Item Selected
        if let catalogController = segue.source as? CatalogPopoverController {
            //print("Item Selected: \(catalogController.selectedItem)")
            
            // Set values
            if let object = catalogController.selectedObject as? EntidadFederativa {
                
                if object != selectedEntidad {
                    
                    selectedEntidad = object
                    // print(selectedEntidad?.valueForKey("id") as! Int)
                  //  carreterasArray = selectedEntidad?.carreteras?.allObjects as! [Carretera]
                    entidadButton.setTitle(selectedEntidad?.nombre, for: UIControlState())
                    datosReport.add(selectedEntidad?.value(forKey: "id") as! Int)
                    objetosEntidades2 = catalogController.objetosEntidades
                    objetosEntidadesDB2 = catalogController.objetosEntidadesDB
                    dataEntidades2 = catalogController.dataEntidades
                }
            }
        }
    }
    // MARK: - Send Web Services
    func sendWS(_ url:String,postRequest:NSMutableDictionary){
        
        print(url)

        var error: NSError?
        
        var JSON: NSString!
        let diccc :NSDictionary = postRequest
        do{
            let theJSONData = try JSONSerialization.data(withJSONObject: diccc, options: JSONSerialization.WritingOptions())
            
            JSON = NSString(data: theJSONData, encoding: String.Encoding.utf8.rawValue)
            print(JSON)
        } catch let error1 as NSError {
            error = error1
        }
        
        
        
        let data1 = ["data1": JSON] as Parameters
        // print("Data: \(data1)")
        SVProgressHUD.show(withStatus: "Enviando información")
        Alamofire.request(url, method: .post, parameters:data1)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                if let error = response.result.error {
                    print("Emergencia Create ERROR: \(error.localizedDescription)")
                    self.showSimpleAlert("Aviso", message: "Ocurrio un error, en tu registro intentelo mas tarde.")
                }else{
                    // print("Response JSON: \(response.result.value!)")
                    if let json = response.result.value{
                        if let rootDict = json as? NSDictionary{
                            let success = rootDict["success"] as! Int
                            let dataArray = rootDict["data"] as! NSArray
                            
                            print("Esto es resultado \(dataArray) o \(json)")
                            
                            if success != 1{
                                self.showSimpleAlert("Aviso", message: "Ocurrio un error, en tu registro intentelo mas tarde.")
                            }else{
                                
                                let alertController = UIAlertController(title: "Aviso", message: "Te has registrado exitosamente", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                    
                                    self.nameUser.text = ""
                                    self.apeMatUser.text = ""
                                    self.apePatUser.text = ""
                                    self.emailUser.text = ""
                                    self.entidadButton.setTitle("Seleccione", for: .normal)
                                    self.dependenciaButton.setTitle("Seleccione", for: .normal)
                                    self.cargoButton.setTitle("Seleccione", for: .normal)
                                    //self.dismissViewControllerAnimated(true, completion: nil)
                                })
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    // Save Reporte ID (emergenciaid)
                }
        }
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Set Catalog Popover Controller
        if segue.identifier == "showPopOverSign" {
            let navController = segue.destination as! UINavigationController
            
            // Set Controller
            let catalogController = navController.viewControllers[0] as! CatalogPopoverController
            if currentButton == entidadButton{
                catalogController.isMultiSelect = false
                if objetosEntidades2.count != 0{
                    catalogController.objetosEntidades = objetosEntidades2
                    catalogController.objetosEntidadesDB = objetosEntidadesDB2
                    catalogController.dataEntidades = dataEntidades2
                }else{
                    
                }
            }else{
                catalogController.isMultiSelect = false
            }
            catalogController.segueType = .popoverSign
            catalogController.catalog = sender as! [NSManagedObject]
            catalogController.title = currentCatalogTitle
            
            // Set Popover
            if let popover = navController.popoverPresentationController {
                popover.delegate = self
                
                // Set Source View (Button)
                popover.sourceView = currentButton
                popover.sourceRect = currentButton.bounds
            }
            
            // Set Date Picker Popover Controller
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    
    //MARK SelectItem
    func itemSelected(_ texto: String, indice : Int) {
        self.navigationController?.popViewController(animated: true)
        print("Este es el Texto \(texto)")
        print("Este es el indice \(indice)")
        if currentButton == dependenciaButton{
            
            dependenciaButton.setTitle(texto, for: UIControlState())
            
            selectedDependencia  = Int(indice + 1)
            
            print("Este es el simobolo de la dependencia \(texto) y este es el valor \(selectedDependencia!)")
            
            
        }else{
            
            cargoButton.setTitle(texto, for: UIControlState())
            
            selectedCargo  = Int(indice + 1)
            
            print("Este es el simobolo del cargo \(texto) y este es el valor \(selectedCargo!)")
            
            
        }



    }

}
