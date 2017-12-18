//
//  NewReportVC.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 20/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SVProgressHUD
import CoreData

// GLOBAL CONSTANTS
//let URL_SERVICES = "http://192.168.1.76:7001" // TEST IN LOCAL
let URL_REPORTES = "http://\(HandlerIO.getHostServices())" // TEST IN LOCAL

let URL_SERVICES = "http://\(HandlerIO.getHostServices())" // REMOTE SERVICES
//let URL_REPORTES = "http://187.188.121.119" // REMOTE SERVICES REPORTS

// Host Loca at 7 Jenuary 2016:  http://10.0.0.6:7001/EmergenciasWS/auth/admseglogin.action

// GET SERVICES
let SERVICIO_ENTIDADES = "/EmergenciasWS/web/Entidadfederativa_view.action"
let SERVICIO_CARRETERAS = "/EmergenciasWS/web/Carretera_movil_view_entidad.action" // Parameters: entidadid
let SERVICIO_TRAMOS = "/EmergenciasWS/web/Tramo_movil_view_carretera.action" // Parameters: carreteraid & entidadid
let SERVICIO_SUBTRAMOS = "/EmergenciasWS/web/Subtramo_movil_view_entidad_tramo.action" // Parameters: entidadid & tramoid
let SERVICIO_DANOS = "/EmergenciasWS/web/Dano_view.action"
let SERVICIO_CAUSAS = "/EmergenciasWS/web/Causaemergencia_view.action"
let SERVICIO_TIPOS = "/EmergenciasWS/web/Tipoemergencia_movil_view_causa.action" // Parameters: causaid
let SERVICIO_CATEGORIAS = "/EmergenciasWS/web/Categoriaemergencia_movil_view_causa.action" // Parameters: tipoid

// POST SERVICES
let SERVICIO_EMERGENCIA_CREATE = "/EmergenciasWS/web/Emergencia_create.action"
let SERVICIO_ACCION_CREATE = "/EmergenciasWS/web/Accion_create.action"
let SERVICIO_CONCEPTO_CREATE = "/EmergenciasWS/web/Actividades_create.action"
let SERVICIO_IMAGE_CREATE = "/EmergenciasWS/web/uploadFileToDB.action"
let SERVICIO_EMERGENCIA_IMAGEN_CREATE = "/EmergenciasWS/web/Emergenciaimagen_create.action"
let SERVICIO_URL_EMERGENCIA_CROQUIS_CREATE = "/EmergenciasWS/web/Emergencia_update.action"

let SERVICIO_CONCEPTO_IMAGEN_CREATE = "/EmergenciasWS/web/Actividadimagen_create.action"
let SERVICIO_VER_E7 = "/EmergenciasWS/web/Ver_E7.action"
let SERVICIO_VER_HISTORICO = "/EmergenciasWS/web/viewHistorico.action"
let SERVICIO_VER_IMAGENES = "/EmergenciasWS/web/viewEmergenciaImages.action"

// Enum State Connection
enum ConnectionState {
    
    case close
    
    case downloadEntidades
    case downloadCarreteras
    case downloadTramos
    case downloadSubtramos
    
    case downloadDanos
    case downloadCausas
    case downloadTipos
    case downloadCategorias
}


class NewReportVC: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate , UITextFieldDelegate{
    
    // MARK: - IBOUtlets
    // Principal Views
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    // Buttons
    @IBOutlet weak var entidadButton: UIButton!
    @IBOutlet weak var carreteraButton: UIButton!
    @IBOutlet weak var tramoButton: UIButton!
    @IBOutlet weak var subtramoButton: UIButton!
    @IBOutlet weak var danosButton: UIButton!
    @IBOutlet weak var causasButton: UIButton!
    @IBOutlet weak var tiposButton: UIButton!
    @IBOutlet weak var categoriasButton: UIButton!
    @IBOutlet weak var transitabilidadButton: UIButton!
    @IBOutlet weak var provisionalDateButton: UIButton!
    @IBOutlet weak var definitivaDateButton: UIButton!
    @IBOutlet weak var agregarCroquisButton: UIButton!
    // TextFields
    @IBOutlet weak var kmInicialTextField: UITextField!
    @IBOutlet weak var kmFinalTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var altitudeTextField: UITextField!
    // TextViews
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var accionesTextView: UITextView!
    // UISwitch
    @IBOutlet weak var autoSwitch: UISwitch!
    @IBOutlet weak var camionesSwitch: UISwitch!
    @IBOutlet weak var todoTipoSwitch: UISwitch!
    @IBOutlet weak var rutaAlternaSwitch: UISwitch!
    
    // MARK: - Variables
    var currentCatalogTitle: String!
    var locationManager: CLLocationManager!
    var currentButton: UIButton!
    let transitabilidadDict = [0: "Nulo", 1: "Total", 2: "Provisional", 3: "Parcial"]
    var provisionalDate: Date!
    var definitivaDate: Date!
    var activeDateButton: UIButton!
    var photos = [Photo]()
    var croquisPhotos = [Photo]()
    var connectionState: ConnectionState = .close
    var numberTramosReqest = 0;
    var numberSubTramosReqest = 0;
    
    
    // MARK: Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    var entidadesArray = [EntidadFederativa]()
    var carreterasArray = [Carretera]()
    var tramosArray = [Tramo]()
    var subtramosArray = [Subtramo]()
    var danosArray = [Dano]()
    var causasArray = [CausaEmergencia]()
    var tiposArray = [TipoEmergencia]()
    var categoriasArray = [CategoriaEmergencia]()
    var transitabilidadesArray = [Transitabilidad]()
    var selectedEntidad: EntidadFederativa?
    var selectedCarretera: Carretera?
    var selectedTramo: Tramo?
    var selectedSubtramo: Subtramo?
    var selectedDano: Dano?
    var selectedCausa: CausaEmergencia?
    var selectedTipo: TipoEmergencia?
    var selectedCategoria: CategoriaEmergencia?
    var selectedTransitabilidad: Transitabilidad?
    
    
    let center = NotificationCenter.default
    var alamoFireManager : Alamofire.SessionManager?
    
    
    
    var causasDanioTypeisDownloaded : Bool = false;
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        // Get Core Data Manager Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        
        
        

        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 160 // seconds
        configuration.timeoutIntervalForResource = 160
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        
        
        
        // Init Location Manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // Set Content View
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewReportVC.actionTapContentView))
        contentView.addGestureRecognizer(tapGesture)
        
        // Set Keyboard
      //  NotificationCenter.default.addObserver(self, selector: #selector(NewReportVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(NewReportVC.KeyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Set TextFields
        //        if selectedSubtramo == nil{
        //            kmInicialTextField.userInteractionEnabled = false
        //            kmFinalTextField.userInteractionEnabled = false
        //        }
        
        kmInicialTextField.addTarget(self, action: #selector(NewReportVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        kmFinalTextField.addTarget(self, action: #selector(NewReportVC.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)

        kmInicialTextField.delegate = self
        kmInicialTextField.tag = 100
        
        kmFinalTextField.delegate = self
        kmFinalTextField.tag = 200


        // Set TextViews
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.backgroundColor = UIColor.white
        accionesTextView.layer.borderWidth = 1.0
        accionesTextView.layer.borderColor = UIColor.lightGray.cgColor
        accionesTextView.backgroundColor = UIColor.white
        // Add Toolbar when show keyboard (Only in iPhone)
        if UIDevice.current.userInterfaceIdiom == .phone {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            toolBar.items = [
                UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "Aceptar", style: .plain, target: self, action: #selector(NewReportVC.actionButtonAceptarInToolBar))]
            
            // Add ToolBar in Keyboard TextViews
            descriptionTextView.inputAccessoryView = toolBar
            accionesTextView.inputAccessoryView = toolBar
            
            // Add ToolBar in Keyboard TextFields
            kmInicialTextField.inputAccessoryView = toolBar
            kmFinalTextField.inputAccessoryView = toolBar
        }
        
        // Set Switch and Button of "Ruta Alterna"
        rutaAlternaSwitch.setOn(false, animated: false)
        agregarCroquisButton.isEnabled = false
        agregarCroquisButton.alpha = 0.75
        
        // Get Local Catalogs, if is empty... Get data from Web Services and save in local
        getCatalogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show Tab Bar
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start Location if service is Enable and if we can Autorized
        whenStartSetAndGetUserLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func whenStartSetAndGetUserLocation(){
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status != CLAuthorizationStatus.denied {
                
                if status == .authorizedWhenInUse {
                    locationManager.startUpdatingLocation()
                }
                else if status == .notDetermined {
                    print("LOCATION IS NOT DETERMINED")
                    locationManager.requestWhenInUseAuthorization()
                }
            }
            else{
                print("LOCATION IS NOT AUTHORIZATION")
            }
        }
        else{
            print("LOCATION SERVICE IS DISABLE")
        }
    }
    
    fileprivate func checkTaskRequestsAndDismissPorgress(_ error: NSError?){
        
         self.alamoFireManager!.session.getAllTasks { (tasks) -> Void in
            
            print("Tasks Running  : \(tasks.count) :connectionState  \(self.connectionState)")
            
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
                    
                case .downloadCarreteras:
                    print("END Download all Carreteras")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getCatalogs()
                    })
                    
                    
                case .downloadTramos:
                    
                    if self.numberTramosReqest == 0{
                        print("END Download all Tramos")
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.getCatalogs()
                        })
                    }
                    
                case .downloadSubtramos:
                    print("END Download all Subtramos")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getCatalogs()
                    })
                    
                    
                case .downloadDanos:
                    print("END Download all Daños")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getDaniosCausasTipos()
                    })
                    
                    
                case .downloadCausas:
                    print("END Download all Causas")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getDaniosCausasTipos()
                    })
                    
                    
                case .downloadTipos:
                    print("END Download all Tipos")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getDaniosCausasTipos()
                    })
                    
                    
                case .downloadCategorias:
                    print("END Download all Categorías")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getDaniosCausasTipos()
                        SVProgressHUD.dismiss()
                    })
                    
                    
                default:
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                    })
                }
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
        self.alamoFireManager!.request( "\(URL_SERVICES)\(SERVICIO_ENTIDADES)", method: .get)
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
    
    fileprivate func downloadCatalogCarreteras(){
        print("Downloading Catalogs Carreteras")
        showProgressWithStatus("Descargando Carreteras...")
        
        connectionState = .downloadCarreteras
        for entidad in entidadesArray {
            self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_CARRETERAS)", method: .get, parameters: ["entidadid": entidad.id.intValue])
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Carreteras by Entidad(\(entidad.id) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Carreteras by Entidad(\(entidad.id)) SUCCESS")
                            
                            // Array of "Carreteras"
                            if let carreteras = rootDict["data"] as? [NSDictionary] {
                                //print("Carreteras: \(carreteras)")
                                
                                // Save "Carreteras" in DB
                                for carreteraDict in carreteras {
                                    
                                    // Create new Carretera
                                    let description = NSEntityDescription.entity(forEntityName: "Carretera", in: self.managedObjectContext)!
                                    let carretera = Carretera(entity: description, insertInto: self.managedObjectContext)
                                    
                                    // Set Attributes
                                    carretera.id =  carreteraDict["id"] as! NSNumber
                                    carretera.nombre = carreteraDict["nombre"] as! String
                                    carretera.entidadFederativa = entidad
                                }
                                
                                // Save
                                do {
                                    try self.managedObjectContext.save()
                                    self.checkTaskRequestsAndDismissPorgress(nil)
                                } catch {
                                    fatalError("Failure to save context in Carreteras with error: \(error)")
                                }
                            }
                        }
                    }
            }
        }
    }
    
    fileprivate func downloadCatalogTramos(_ carreteras: [Carretera]){
        print("Downloading Catalog Tramos")
        showProgressWithStatus("Descargando Tramos...")
        
        connectionState = .downloadTramos
        for carretera in carreteras {
            let parameters = ["carreteraid": carretera.id.intValue, "entidadid": carretera.entidadFederativa.id.intValue]
            
            numberTramosReqest += 1
            print("Number Tramos Requests: \(numberTramosReqest) in START request")
            self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_TRAMOS)", method: .get, parameters: parameters)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Tramos by Carretera(\(carretera.id)) ERROR: \(error.localizedDescription)")
                        //print("Download Tramos by Carretera(\(carretera.id)) ERROR")
                        self.numberTramosReqest-=1
                        print("Number Tramos Requests: \(self.numberTramosReqest) in END request")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        self.numberTramosReqest-=1
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Tramos by Carretera(\(carretera.id)) SUCCESS")
                            
                            // Array of "Tramos"
                            if let tramos = rootDict["data"] as? [NSDictionary] {
                                //print("Tramos: \(tramos)")
                                
                                // Save "Tramos" in DB
                                for tramoDict in tramos {
                                    
                                    // Create new Tramo
                                    let description = NSEntityDescription.entity(forEntityName: "Tramo", in: self.managedObjectContext)!
                                    let tramo = Tramo(entity: description, insertInto: self.managedObjectContext)
                                    
                                    // Set Attributes
                                    tramo.id =  tramoDict["id"] as! NSNumber
                                    tramo.nombre = tramoDict["nombre"] as! String
                                    tramo.carretera = carretera
                                }
                                
                                // Save
                                do {
                                    try self.managedObjectContext.save()
                                    print("Number Tramos Requests: \(self.numberTramosReqest) in END request")
                                    self.checkTaskRequestsAndDismissPorgress(nil)
                                } catch {
                                    fatalError("Failure to save context in Carreteras with error: \(error)")
                                }
                            }
                        }
                    }
            }
            
            //Set time out to avoid multiple threads.
            usleep(10000);
            
            
        }
    }
    
    fileprivate func downloadCatalogSubtramos(_ tramos: [Tramo]){
        print("Downloading Catalog Subtramos")
        showProgressWithStatus("Descargando Subtramos...")
        
        connectionState = .downloadSubtramos
        for tramo in tramos {
            numberSubTramosReqest += 1
            let parameters = ["tramoid": tramo.id.intValue, "entidadid": tramo.carretera.entidadFederativa.id.intValue]
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = 2 // seconds
            
            self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_SUBTRAMOS)", method: .get, parameters: parameters)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Subtramos by Tramo(\(tramo.id)) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        self.numberSubTramosReqest-=1
                        
                    }else{
                        self.numberSubTramosReqest-=1
                        
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Subtramos by Tramo(\(tramo.id)) SUCCESS")
                            //print("JSON Subtramos: \(rootDict)")
                            
                            // Array of "Subtramos"
                            if let subtramos = rootDict["data"] as? [NSDictionary] {
                                //print("Subtramos: \(subtramos)")
                                
                                // Save "Subtramos" in DB
                                for subtramoDict in subtramos {
                                    
                                    // Create new Subtramo
                                    //let description = NSEntityDescription.entityForName("Subtramo", inManagedObjectContext: self.managedObjectContext)!
                                    
                                    
                                    
                                    let subtramo = NSEntityDescription.insertNewObject(forEntityName: "Subtramo", into: self.managedObjectContext) as! Subtramo
                                    
                                    
                                 //   let subtramo = Subtramo(entity: description, insertIntoManagedObjectContext: //self.managedObjectContext)
                                    
                                    // Set Attributes
                                    subtramo.id =  subtramoDict["id"] as! NSNumber
                                    subtramo.nombre =  subtramoDict["nombre"] as! String
                                    subtramo.kmInicial = subtramoDict["kminicial"] as! NSNumber
                                    subtramo.kmFinal = subtramoDict["kmfinal"] as! NSNumber
                                    subtramo.tramo = tramo
                                }
                                
                                // Save
                                do {
                                    print("Number SubTramos Requests: \(self.numberSubTramosReqest) in END request")
                                    
                                    try self.managedObjectContext.save()
                                    self.checkTaskRequestsAndDismissPorgress(nil)
                                    
                                } catch {
                                    fatalError("Failure to save context in Carreteras with error:")
                                }
                            }
                        }
                    }
            }
            
            
            usleep(10000);
            
        }
    }
    
    fileprivate func downloadCatalogDanos(){
        print("Downloading Catalog Daños")
        showProgressWithStatus("Descargando Daños...")
        
        connectionState = .downloadDanos
        self.alamoFireManager!.request( "\(URL_SERVICES)\(SERVICIO_DANOS)", method: .get)
            .responseJSON { response in
                
                if let error = response.result.error {
                    print("Download Daños ERROR: \(error.localizedDescription)")
                    self.checkTaskRequestsAndDismissPorgress(error as NSError)
                    
                }else{
                    
                    if let rootDict = response.result.value as? NSDictionary {
                        print("Download Daños SUCCESS")
                        
                        // Array of "Danos"
                        if let danos = rootDict["data"] as? [NSDictionary] {
                            print("Daños: \(danos)")
                            print("El numero de danos es \(danos.count)")
                            
                            // Save "Subtramos" in DB
                            for danoDict in danos {
                                
                                // Create new Daño
                                let description = NSEntityDescription.entity(forEntityName: "Dano", in: self.managedObjectContext)!
                                let dano = Dano(entity: description, insertInto: self.managedObjectContext)
                                
                                // Set Attributes
                                dano.id =  danoDict["danoid"] as! NSNumber
                                dano.nombre =  danoDict["nombre"] as! String
                            }
                            
                            // Save
                            do {
                                try self.managedObjectContext.save()
                                self.checkTaskRequestsAndDismissPorgress(nil)
                                
                            } catch {
                                fatalError("Failure to save context in Danos with error: \(error)")
                            }
                        }
                    }
                }
        }
    }
    
    fileprivate func downloadCatalogCausas(){
        print("Downloading Catalog Causas")
        showProgressWithStatus("Descargando Causas...")
        
        connectionState = .downloadCausas
        self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_CAUSAS)", method: .get)
            .responseJSON { response in
                
                if let error = response.result.error {
                    print("Download Causas ERROR: \(error.localizedDescription)")
                    self.checkTaskRequestsAndDismissPorgress(error as NSError)
                    
                }else{
                    
                    if let rootDict = response.result.value as? NSDictionary {
                        print("Download Causas SUCCESS")
                        
                        // Array of "Causas"
                        if let causas = rootDict["data"] as? [NSDictionary] {
                            print("Causas: \(causas)")
                            print("El numero de causas es \(causas.count)")
                            
                            
                            // Save "Causas" in DB
                            for causaDict in causas{
                                
                                // Create new Causa
                                let description = NSEntityDescription.entity(forEntityName: "CausaEmergencia", in: self.managedObjectContext)!
                                let causa = CausaEmergencia(entity: description, insertInto: self.managedObjectContext)
                                
                                // Set Attributes
                                causa.id = causaDict["causaid"] as! NSNumber
                                causa.nombre = causaDict["nombre"] as! String
                            }
                        }
                        
                        // Save
                        do {
                            
                            try self.managedObjectContext.save()
                            self.checkTaskRequestsAndDismissPorgress(nil)
                            
                        } catch {
                            fatalError("Failure to save context in Causas with error: \(error)")
                        }
                    }
                }
        }
    }
    
    fileprivate func downloadCatalogTipos(_ causas: [CausaEmergencia]){
        print("Downloading Catalog Tipos")
        showProgressWithStatus("Descargando Tipos...")
        
        connectionState = .downloadTipos
        for causa in causas{
            self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_TIPOS)", method: .get, parameters: ["causaid": causa.id.intValue])
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Tipos by Causa(\(causa.id.intValue)) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        print(response.result.value)
                        
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Tipos by Causa(\(causa.id.intValue)) SUCCESS")
                            
                            // Array of "Tipos"
                            if let tipos = rootDict["data"] as? [NSDictionary] {
                                //print("Tipos: \(causas)")
                                
                                // Save "Causas" in DB
                                for tipoDict in tipos{
                                    
                                    // Create new Tipo
                                    let description = NSEntityDescription.entity(forEntityName: "TipoEmergencia", in: self.managedObjectContext)!
                                    let tipo = TipoEmergencia(entity: description, insertInto: self.managedObjectContext)
                                    
                                    // Set Attributes
                                    tipo.id = tipoDict["id"] as! NSNumber
                                    tipo.nombre = tipoDict["nombre"] as! String
                                    tipo.causaEmergencia = causa
                                }
                            }
                            
                            // Save
                            do {
                                try self.managedObjectContext.save()
                                self.checkTaskRequestsAndDismissPorgress(nil)
                                
                            } catch {
                                fatalError("Failure to save context in Tipos of Causa(\(causa.id.intValue)) with error: \(error)")
                            }
                        }
                    }
            }
            
            usleep(5000);
            
        }
    }
    
    fileprivate func downloadCatalogCategorias(_ tipos: [TipoEmergencia]){
        print("Downloading Catalog Categorias")
        showProgressWithStatus("Descargando Categorías...")
        
        connectionState = .downloadCategorias
        for tipo in tipos{
            self.alamoFireManager!.request("\(URL_SERVICES)\(SERVICIO_CATEGORIAS)", method: .get, parameters: ["tipoid": tipo.id.intValue])
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Categorias by Tipo(\(tipo.id.intValue)) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Categorias by Tipo(\(tipo.id.intValue)) SUCCESS")
                            
                            // Array of "Categorias"
                            if let categorias = rootDict["data"] as? [NSDictionary] {
                                //print("Categorias: \(categorias)")
                                
                                // Save "Categorias" in DB
                                for categoriaDict in categorias{
                                    
                                    // Create new Tipo
                                    let description = NSEntityDescription.entity(forEntityName: "CategoriaEmergencia", in: self.managedObjectContext)!
                                    let categoria = CategoriaEmergencia(entity: description, insertInto: self.managedObjectContext)
                                    
                                    // Set Attributes
                                    categoria.id = categoriaDict["id"] as! NSNumber
                                    categoria.nombre = categoriaDict["nombre"] as! String
                                    categoria.tipoEmergencia = tipo
                                }
                            }
                            
                            // Save
                            do {
                                
                                try self.managedObjectContext.save()
                                self.checkTaskRequestsAndDismissPorgress(nil)
                                
                            } catch {
                                fatalError("Failure to save context in Categorias of Tipo(\(tipo.id.intValue)) with error: \(error)")
                            }
                        }
                    }
            }
            
            usleep(5000);
            
        }
    }
    
    
    fileprivate func getCatalogs(){
        print("\n\(URL_SERVICES)\n\(URL_SERVICES)\(SERVICIO_ENTIDADES)")
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
                
                // Validate if Catalog "Carreteras" is Storage
                if let carreteras = HandlerIO.getEntityStorage("Carretera") as? [Carretera] {
                    if carreteras.isEmpty{
                        print("Carreteras is Empty")
                        
                        // 2. Download "Carreteras by Entidad Federativa"
                        downloadCatalogCarreteras()
                    }else{
                        print("# Carreteras in storage: \(carreteras.count)")
                        
                        // Validate if catalog "Tramos" is Storage
                        if let tramos = HandlerIO.getEntityStorage("Tramo") as? [Tramo] {
                            if tramos.isEmpty{
                                print("Tramos is Empty")
                                
                                // 3. Download "Tramos by Carretera"
                                downloadCatalogTramos(carreteras)
                            }else{
                                print("# Tramos in storage: \(tramos.count)")
                                
                                // Validate if catalog "Subtramos" is Storage
                                if let subtramos = HandlerIO.getEntityStorage("Subtramo") as? [Subtramo] {
                                    if subtramos.isEmpty{
                                        print("Subtramos is Empty")
                                        
                                        // 4. Download "Subtramos by Tramo"
                                        downloadCatalogSubtramos(tramos)
                                    }else{
                                        print("# Subtramos in storage: \(subtramos.count)")
                                        
                                        // Validate if catalog "Daños causados" is Storage
                                        if !causasDanioTypeisDownloaded{
                                            getDaniosCausasTipos()
                                            causasDanioTypeisDownloaded = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func getDaniosCausasTipos(){
        
        // Validate if catalog "Daños causados" is Storage
        
        if let danos = HandlerIO.getEntityStorage("Dano") as? [Dano]{
            if danos.isEmpty{
                print("Daños is Empty")
                
                // 1. Download "Daños"
                downloadCatalogDanos()
            }else{
                print("# Daños in storage: \(danos.count)")
                danosArray = danos
                
                // Get Catalog "Causas de la Incidencia"
                if let causas = HandlerIO.getEntityStorage("CausaEmergencia") as? [CausaEmergencia]{
                    if causas.isEmpty {
                        print("Causas is Empty")
                        
                        // 1. Download "Causas de la Incidencia"
                        downloadCatalogCausas()
                    }else{
                        print("# Causas in storage: \(causas.count)")
                        causasArray = causas
                        
                        // Validate if catalog "Tipo de Emergencia" is Storage
                        if let tipos = HandlerIO.getEntityStorage("TipoEmergencia") as? [TipoEmergencia]{
                            if tipos.isEmpty{
                                print("Tipos is Empty")
                                
                                // Download "Tipos de Emergencia"
                                //print(causas)
                                downloadCatalogTipos(causas)
                            }else{
                                print("# Tipos in storage: \(tipos.count)")
                                tiposArray = tipos
                                
                                // Validate if catalog "Categorias" is Storage
                                if let categorias = HandlerIO.getEntityStorage("CategoriaEmergencia") as? [CategoriaEmergencia]{
                                    if categorias.isEmpty{
                                        print("Categorias is Empty")
                                        
                                        // Download "Categorias"
                                        downloadCatalogCategorias(tipos)
                                    }else{
                                        print("# Categorias in storage: \(categorias.count)")
                                        categoriasArray = categorias
                                        
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
                                                    
                                                    
                                                    print("TRANS Los valores obtenidos son:  \(transitabilidad.id)     \(transitabilidad.nombre)")
                                                    
                                                }
                                                
                                                // Save
                                                do {
                                                    try self.managedObjectContext.save()
                                                    self.getCatalogs()
                                                } catch {
                                                    fatalError("Failure to save context in Transitabilidad with error: \(error)")
                                                }
                                            }else{
                                                print("# Transitabilidad in storage: \(transitabilidades.count)")
                                                transitabilidadesArray = transitabilidades
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
        
    }
    
    
    
    fileprivate func adjustInsetForKeyboard(_ show: Bool, notification: Notification){
        
        // Get value
        let userInfo = (notification as NSNotification).userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = keyboardFrame.height * (show ? 1 : -1)
        //keyboardFrame.height * (show ? 1 : -1)
        // Set ScrollView
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    fileprivate func clearAndResetAllValues(){
        
        // First Section
        selectedEntidad = nil
        selectedCarretera = nil
        selectedTramo = nil
        selectedSubtramo = nil
        entidadButton.setTitle(defaultButtonTitle, for: UIControlState())
        carreteraButton.setTitle(defaultButtonTitle, for: UIControlState())
        tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
        subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
        kmInicialTextField.text = ""
        kmFinalTextField.text = ""
        
        // Second Section
        selectedDano = nil
        selectedCausa = nil
        selectedTipo = nil
        selectedCategoria = nil
        danosButton.setTitle(defaultButtonTitle, for: UIControlState())
        causasButton.setTitle(defaultButtonTitle, for: UIControlState())
        tiposButton.setTitle(defaultButtonTitle, for: UIControlState())
        categoriasButton.setTitle(defaultButtonTitle, for: UIControlState())
        
        descriptionTextView.text = ""
        
        // Set "Transitabilidad"
        selectedTransitabilidad = nil
        autoSwitch.setOn(false, animated: false)
        camionesSwitch.setOn(false, animated: false)
        todoTipoSwitch.setOn(false, animated: false)
        
        transitabilidadButton.setTitle(defaultButtonTitle, for: UIControlState())
        
        // Set Fechas
        provisionalDate = nil
        definitivaDate = nil
        provisionalDateButton.setTitle(defaultButtonTitle, for: UIControlState())
        definitivaDateButton.setTitle(defaultButtonTitle, for: UIControlState())
        
        rutaAlternaSwitch.setOn(false, animated: false)
        accionesTextView.text = ""
        
        // Set Photos
        photos.removeAll()
        croquisPhotos.removeAll()
    }
    
    
    // MARK: - Public Methods
    
    func actionTapContentView(){
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification){
        adjustInsetForKeyboard(true, notification: notification)
    }
    
    func KeyboardWillHide(_ notification: Notification){
        adjustInsetForKeyboard(false, notification: notification)
    }
    
    func actionButtonAceptarInToolBar(){
        self.view.endEditing(true)
    }
    
    
    // MARK: - IBAction Methods
    
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
            print(object)
            
        case carreteraButton:
            
            if selectedEntidad == nil {
                Utilities.showAlertWhenLackCatalogsInController(self)
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
            
            // Cases of "Tipos de daños"
        case danosButton:
            
            if  danosArray.isEmpty{
                Utilities.showAlertWhenLackCatalogsInController(self)
                return
            }
            
            currentCatalogTitle = "Daños causados"
            currentButton = danosButton
            object = danosArray
            
        case causasButton:
            
            if causasArray.isEmpty{
                Utilities.showAlertWhenLackCatalogsInController(self)
                return
            }
            
            currentCatalogTitle = "Causas de la incidencia"
            currentButton = causasButton
            object = causasArray
            
        case tiposButton:
            
            if selectedCausa == nil {
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Causa de la Incidencia", inController: self)
                return
            }
            
            currentCatalogTitle = "Tipos de incidencia"
            currentButton = tiposButton
            object = tiposArray
            
        case categoriasButton:
            
            if let tipo = selectedTipo{
                if tipo.nombre != "HURACAN" {
                    Utilities.showSimpleAlertControllerMessage("El tipo de incidencia \(tipo.nombre) no tiene categorias", inController: self)
                    return
                }
            }
            else{
                Utilities.showSimpleAlertControllerMessage("SSeleccione primero Tipo de Incidencia", inController: self)
                return
            }
            
            currentCatalogTitle = "Categorías"
            currentButton = categoriasButton
            object = categoriasArray
            
            // Case of "Transitabilidad"
        case transitabilidadButton:
            currentCatalogTitle = "Transitabilidad"
            currentButton = transitabilidadButton
            object = transitabilidadesArray
            
        default:
            print("Selected any other button that is not Catalog")
        }
        
        // Show Popover
        self.performSegue(withIdentifier: "ShowPopover", sender: object)
    }
    
    @IBAction func actionButtonDatePicker(_ sender: AnyObject){
        activeDateButton = sender as! UIButton
        self.performSegue(withIdentifier: "ShowDatePickerPopover", sender: sender)
    }
    
    @IBAction func actionButtonUpdateLocation(_ sender: AnyObject) {
        
        switch CLLocationManager.authorizationStatus(){
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            SVProgressHUD.show()
            locationManager.startUpdatingLocation()
        case .denied:
            if CLLocationManager.locationServicesEnabled() {
                
                let alertController = UIAlertController(
                    title: "Permiso Denegado",
                    message: "Incidencias no tiene permitido usar la localización, favor de ir a configuraciones y permitir uso",
                    preferredStyle: .alert)
                
                let actionCancel = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                let actionSettings = UIAlertAction(title: "Config.", style: .default, handler: { (action) -> Void in
                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionSettings)
                
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                
                let alertController = UIAlertController(
                    title: "Localizacion Deshabilitada",
                    message: "La localización esta deshabilidata, vaya a Configuraciones > Privacidad y habilitar Servicio de Localización",
                    preferredStyle: .alert)
                
                let actionCancel = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
                let actionSettings = UIAlertAction(title: "Config.", style: .default, handler: { (action) -> Void in
                    if let url = URL(string:"prefs:root=LOCATION_SERVICES") {
                        UIApplication.shared.openURL(url)
                    }
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionSettings)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
        default:
            print("Location Authorization Status is RESTRICTED")
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
    

    
    
    @IBAction func actionButtonSaveAlert(_ sender: AnyObject){
        // Validate all Values, recopilate all values faild and show in AlertView
        var message = ""
        let kmInicial = Double((selectedSubtramo?.kmInicial)!)
        let kmFinal = Double((selectedSubtramo?.kmFinal)!)

        // 1. "Datos de Ubicación"
        if selectedEntidad == nil{
            message += "Entidad \n"
        }
        if selectedCarretera == nil{
            message += "Carretera \n"
        }
        if selectedTramo == nil{
            message += "Tramo \n"
        }
        if selectedSubtramo == nil{
            message += "Subtramo \n"
        }
        if kmInicialTextField.text!.isEmpty{
            message += "Km Inicial \n"
            

        }else{
            let kmMetrosInicialPoint = kmInicialTextField.text!.replacingOccurrences(of: "+", with: ".")
            let kmMetrosInicialDobule : Double = Double(kmMetrosInicialPoint)!
            
            
            if kmMetrosInicialDobule < kmInicial{
                message += "Km Inicial no esta en el rango del subtramo \n"
            }
        }
        
        if kmFinalTextField.text!.isEmpty{
            message += "Km Final \n"
            
        }else{
            
            let kmMetrosFinalPoint = kmFinalTextField.text!.replacingOccurrences(of: "+", with: ".")
            let kmMetrosFinalDobule : Double = Double(kmMetrosFinalPoint)!
            
            if kmMetrosFinalDobule > kmFinal{
                message += "Km Final no esta en el rango del subtramo  \n"
            }
        }
        
        
        if latitudeTextField.text!.isEmpty && longitudeTextField.text!.isEmpty && altitudeTextField.text!.isEmpty{
            message += "Localización \n"
        }
        
        // 2. "Tipos de Daños"
        if selectedDano == nil{
            message += "Daño causado \n"
        }
        if selectedCausa == nil{
            message += "Causa de la incidencia \n"
        }
        if selectedTipo == nil{
            message += "Tipo de incidencia \n"
        }
        if selectedCategoria == nil {
            if let tipo = selectedTipo{
                if tipo.nombre == "HURACAN"{
                    message += "Categoría \n"
                }
            }
            else{
                message += "Categoría \n"
            }
        }
        if descriptionTextView.text.isEmpty{
            message += "Descripción \n"
        }
        if selectedTransitabilidad == nil{
            message += "Transitabilidad \n"
        }
        if provisionalDate == nil{
            message += "Fecha Provisional \n"
        }
        if definitivaDate == nil{
            message += "Fecha Definitiva \n"
        }
        if accionesTextView.text.isEmpty{
            message += "Acciones \n"
        }
        if photos.isEmpty{
            message += "Foto(s) \n"
        }
        
        // Save or show alert to validate
        if message.isEmpty{
            
            // Create New Alert
            let description = NSEntityDescription.entity(forEntityName: "Reporte", in: self.managedObjectContext)!
            let reporte = Reporte(entity: description, insertInto: self.managedObjectContext)
            
            // Set Attributes
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyyHHmmssSS"
            let id: Int64 = Int64(dateFormatter.string(from: Date()))!
            reporte.reporteId = NSNumber(value: id as Int64)
            
            reporte.entidadFederativa = selectedEntidad!
            reporte.carretera = selectedCarretera!
            reporte.tramo = selectedTramo!
            reporte.subtramo = selectedSubtramo!
            //TODO
            //Corregir
            let kmMetrosInicialDouble : String = kmInicialTextField.text!
            let kmMetrosFinalDouble : String = kmFinalTextField.text!
            
            
            /*let fullNameArr = kmMetrosInicialDouble.componentsSeparatedByString("+")
            
            var kmString: String = fullNameArr[0]
            var metrosString: String = fullNameArr[1]
            
            let fullNameArr2 = kmMetrosFinalDouble.componentsSeparatedByString("+")
            var kmString2: String = fullNameArr2[0]
            var metrosString2: String = fullNameArr2[1]*/
            
            let kmMetrosInicialPoint = kmMetrosInicialDouble.replacingOccurrences(of: "+", with: ".")
            let kmMetrosInicialDobule : Double = Double(kmMetrosInicialPoint)!
            
            let kmMetrosFinalPoint = kmMetrosFinalDouble.replacingOccurrences(of: "+", with: ".")
            let kmMetrosFinalDobule : Double = Double(kmMetrosFinalPoint)!
            
            
            print("kmMetrosInicialDobule (\(kmMetrosInicialDobule))")
            
            print("kmMetrosFinalDobule (\(kmMetrosFinalDobule))")

            
            
            
            reporte.kmInicial = kmMetrosInicialDobule as? NSNumber
            reporte.kmFinal = kmMetrosFinalDobule as? NSNumber
            reporte.latitud = Double(latitudeTextField.text!)! as NSNumber?
            reporte.longitud = Double(longitudeTextField.text!)! as NSNumber?
            reporte.altitud = Double(altitudeTextField.text!)! as NSNumber?
            reporte.dano = selectedDano!
            reporte.causaEmergencia = selectedCausa!
            reporte.tipoEmergencia = selectedTipo!
            reporte.categoriaEmergencia = selectedCategoria
            reporte.descripcion = descriptionTextView.text!
            reporte.transitabilidad = selectedTransitabilidad!
            
            // Save "Tipo de vehiculos que pueden transitar":
            var tipoVehiculo: String?
            print("todo tipo \(todoTipoSwitch.isOn)")
            if todoTipoSwitch.isOn{
                tipoVehiculo = "Todo tipo"
            }else if camionesSwitch.isOn{
                tipoVehiculo = "Camiones"
            }else if autoSwitch.isOn{
                tipoVehiculo = "Autos"
            }
            reporte.tipoVehiculo = tipoVehiculo
            
            reporte.fechaProvisional = provisionalDate
            reporte.fechaDefinitiva = definitivaDate
            reporte.rutaAlterna = rutaAlternaSwitch.isOn as NSNumber
            reporte.accionesRealizadas = accionesTextView.text!
            reporte.hasBeedModified = false
            // Save "Photos"
            for photo in photos{
                
                // Create New Model Object "Imagen"
                let description = NSEntityDescription.entity(forEntityName: "Imagen", in: self.managedObjectContext)!
                let imagen = Imagen(entity: description, insertInto: self.managedObjectContext)
                
                // Set Attributes
                imagen.id = NSNumber(value: id as Int64)
                imagen.name = photo.name
                imagen.file = photo.data
                imagen.type = 0
                
                // Add "Imagen" al Reporte
                reporte.addImagenToReporte(imagen)
            }
            
            
            // Save "Photos croquis"
            for photo in croquisPhotos{
                
                // Create New Model Object "Imagen"
                let description = NSEntityDescription.entity(forEntityName: "Imagen", in: self.managedObjectContext)!
                let imagen = Imagen(entity: description, insertInto: self.managedObjectContext)
                
                // Set Attributes
                imagen.id = NSNumber(value: id as Int64)
                imagen.name = photo.name
                imagen.file = photo.data
                imagen.type = 1
                
                // Add "Imagen" al Reporte
                reporte.addImagenToReporte(imagen)
            }
            
            // Save
            do {
                try self.managedObjectContext.save()
                
                // Create new Transitabilidad
                let accionEntity = NSEntityDescription.entity(forEntityName: "Accion", in: self.managedObjectContext)!
                let accion = Accion(entity: accionEntity, insertInto: self.managedObjectContext)
                
                accion.descripcion = accionesTextView.text!
                
                accion.transito =  selectedTransitabilidad!.nombre
                accion.activo = 1
                accion.tipoVehiculo = tipoVehiculo
                accion.reporte = reporte
                //4
                // Set Attributes
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyyyyHHmmssSS"
                let id: Int64 = Int64(dateFormatter.string(from: Date()))!
                accion.id = NSNumber(value: id as Int64)
                reporte.hasBeedModified = true
                
                do{
                    try managedObjectContext.save()
                    
                }catch let error as NSError {
                    print("Could not save \(error), \(error.userInfo))")
                    
                }
                
                
                // Show Progress Success
                SVProgressHUD.showSuccess(withStatus: "Alerta guardada!")
                
                // Clear or Reset all Values
                self.clearAndResetAllValues()
                
            } catch {
                fatalError("Failure to save context in Entidades Federativas, with error: \(error)")
            }
        }
        else{
            // Alert Controller
            let alert = UIAlertController(title: "Datos faltantes", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionSwitchRutaAlterna(_ sender: UISwitch) {
        
        if sender.isOn{
            agregarCroquisButton.isEnabled = true
            agregarCroquisButton.alpha = 1.0
        }else{
            if !croquisPhotos.isEmpty{
                
                // Show Alert to request Delete croquis images
                let alertController = UIAlertController(title: "Imágenes de Cróquis", message: "Al deshabilitar ruta alterna se eliminaran las imágenes de croquis que hayas guardado", preferredStyle: .alert)
                // Actions
                let actionAccept = UIAlertAction(title: "Aceptar", style: .destructive, handler: { (action) -> Void in
                    
                    // Delete Images of "Cróquis"
                    self.croquisPhotos.removeAll()
                    
                    // Disable button
                    self.agregarCroquisButton.isEnabled = false;
                    self.agregarCroquisButton.alpha = 0.75
                })
                let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) -> Void in
                    // Turn to On
                    sender.setOn(true, animated: true)
                })
                alertController.addAction(actionAccept)
                alertController.addAction(actionCancel)
                self.present(alertController, animated: true, completion: nil)
            }else{
                // Disable button
                agregarCroquisButton.isEnabled = false;
                agregarCroquisButton.alpha = 0.75
            }
        }
    }
    
    
    // MARK: - Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set Catalog Popover Controller
        if segue.identifier == "ShowPopover" {
            let navController = segue.destination as! UINavigationController
            
            // Set Controller
            let catalogController = navController.viewControllers[0] as! CatalogPopoverController
            catalogController.segueType = .popover
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
        }else if segue.identifier == "ShowDatePickerPopover"{
            let navController = segue.destination as! UINavigationController
            
            // Set Controller
            let datePickerController = navController.viewControllers[0] as! DatePickerPopoverController
            datePickerController.segueType = 0
            if let button = sender as? UIButton{
                if button.titleLabel?.text != "Seleccione"{
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    datePickerController.selectedDate = dateFormatter.date(from: (button.titleLabel?.text)!)
                    
                }
            }
            
            // Set Popover
            if let popover = navController.popoverPresentationController {
                popover.delegate = self
                
                // Set Source View (Button)
                if let button = sender as? UIButton{
                    popover.sourceView = button
                    popover.sourceRect = button.bounds
                }
            }
            
            // Set Photos Collection View Controller
        }else if segue.identifier == "ShowPhotosCollectionVC"{
            let photosCollectionVC = segue.destination as! PhotosCollectionVC
            photosCollectionVC.delegate = self
            photosCollectionVC.photos = self.photos
            photosCollectionVC.photoType = .reporte
            
            // Set Photos Collection VC from Image Croquis
        }else if segue.identifier == "ShowCollectionPhotosCroquis"{
            let photosCollectionVC = segue.destination as! PhotosCollectionVC
            photosCollectionVC.delegate = self
            photosCollectionVC.photos = self.croquisPhotos
            photosCollectionVC.photoType = .croquis
        }
    }
    
    @IBAction func unwindWithSelectedItem(_ segue: UIStoryboardSegue){
        
        // Get Item Selected
        if let catalogController = segue.source as? CatalogPopoverController {
            //print("Item Selected: \(catalogController.selectedItem)")
            
            // Set values
            if let object = catalogController.selectedObject as? EntidadFederativa {
                
                if object != selectedEntidad {
                    
                    selectedEntidad = object
                    carreterasArray = selectedEntidad?.carreteras?.allObjects as! [Carretera]
                    entidadButton.setTitle(selectedEntidad?.nombre, for: UIControlState())
                    
                    // Set Other Default Values in Cascade
                    selectedCarretera = nil
                    carreteraButton.setTitle(defaultButtonTitle, for: UIControlState())
                    tramosArray.removeAll()
                    selectedTramo = nil
                    tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedSubtramo = nil
                    subtramosArray.removeAll()
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    kmInicialTextField.text = ""
                    kmInicialTextField.isUserInteractionEnabled = true
                    kmFinalTextField.text = ""
                    kmFinalTextField.isUserInteractionEnabled = true
                }
            }
            else if let object = catalogController.selectedObject as? Carretera {
                
                if object != selectedCarretera{
                    
                    selectedCarretera = object
                    tramosArray = selectedCarretera?.tramos?.allObjects as! [Tramo]
                    carreteraButton.setTitle(selectedCarretera?.nombre, for: UIControlState())
                    
                    // Set Other Default Values in Cascade
                    selectedTramo = nil
                    tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedSubtramo = nil
                    subtramosArray.removeAll()
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    kmInicialTextField.text = ""
                    kmInicialTextField.isUserInteractionEnabled = true
                    kmFinalTextField.text = ""
                    kmFinalTextField.isUserInteractionEnabled = true
                }
                
            }
            else if let object = catalogController.selectedObject as? Tramo {
                
                if object != selectedTramo {
                    
                    selectedTramo = object
                    tramoButton.setTitle(selectedTramo?.nombre, for: UIControlState())
                    subtramosArray = selectedTramo?.subtramos.allObjects as! [Subtramo]
                    
                    // Set Other Default Values in Cascade
                    selectedSubtramo = nil
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    kmInicialTextField.text = ""
                    kmInicialTextField.isUserInteractionEnabled = true
                    kmFinalTextField.text = ""
                    kmFinalTextField.isUserInteractionEnabled = true
                }
            }
            else if let object = catalogController.selectedObject as? Subtramo {
                selectedSubtramo = object
                subtramoButton.setTitle(selectedSubtramo?.nombre, for: UIControlState())
                //TODO Mascara de 3 digitos
                
                let kmInicial = (selectedSubtramo?.kmInicial)!
                let kmFinal = (selectedSubtramo?.kmFinal)!

                print("El texto de KM inicial(\(kmInicial))")
                print("El texto de KM final(\(kmFinal))")

                let kmInicialint:Int = Int(kmInicial)
                let kmFinalint:Int = Int(kmFinal)

                print("El texto de KM inicial entero es (\(kmInicialint))")
                print("El texto de KM final entero es (\(kmFinalint))")

                
                let numberOfPlaces:Double = 3.0
                let powerOfTen:Double = pow(10.0, numberOfPlaces)
                let targetedDecimalPlaces:Double = round((Double(kmInicial).truncatingRemainder(dividingBy: 1.0)) * powerOfTen) / powerOfTen
                let targetedDecimalPlacesfinal:Double = round((Double(kmFinal).truncatingRemainder(dividingBy: 1.0)) * powerOfTen) / powerOfTen

                print("El texto de KM inicial decimal es (\(targetedDecimalPlaces*1000))")

                print("El texto de KM final decimal es (\(targetedDecimalPlacesfinal*1000))")
                
                let metrosInicialint:Int = Int(targetedDecimalPlaces*1000)
                let metrosFinalint:Int = Int(targetedDecimalPlacesfinal*1000)
                
                
                print("El texto de METROS inicial entero es (\(metrosInicialint))")
                
                print("El texto de METROS final entero es (\(metrosFinalint))")

                
                kmInicialTextField.text = String(format: "%03d", kmInicialint)+"+"+String(format: "%03d", metrosInicialint)
                kmFinalTextField.text = String(format: "%03d", kmFinalint)+"+"+String(format: "%03d", metrosFinalint)
                
                kmInicialTextField.isUserInteractionEnabled = true // Change to TRUE
                kmFinalTextField.isUserInteractionEnabled = true // Change to TRUE
            }
            else if let object = catalogController.selectedObject as? Dano{
                selectedDano = object
                danosButton.setTitle(selectedDano?.nombre, for: UIControlState())
            }
            else if let object = catalogController.selectedObject as? CausaEmergencia{
                
                if object != selectedCausa{
                    
                    selectedCausa = object
                    causasButton.setTitle(selectedCausa?.nombre, for: UIControlState())
                    tiposArray = selectedCausa?.tipoEmergencias?.allObjects as! [TipoEmergencia]
                    
                    // Set Other Default Values in Cascade
                    selectedTipo = nil
                    tiposButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedCategoria = nil
                    categoriasArray.removeAll()
                    categoriasButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
                
            }
            else if let object = catalogController.selectedObject as? TipoEmergencia{
                
                if object != selectedTipo {
                    
                    selectedTipo = object
                    tiposButton.setTitle(selectedTipo?.nombre, for: UIControlState())
                    categoriasArray = selectedTipo?.categoriaEmergencias?.allObjects as! [CategoriaEmergencia]
                    
                    // Set Other Default Values in Cascade
                    selectedCategoria = nil
                    categoriasButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
            }
            else if let object = catalogController.selectedObject as? CategoriaEmergencia{
                selectedCategoria = object
                categoriasButton.setTitle(selectedCategoria?.nombre, for: UIControlState())
            }
            else if let object = catalogController.selectedObject as? Transitabilidad{
                selectedTransitabilidad = object
                transitabilidadButton.setTitle(selectedTransitabilidad?.nombre, for: UIControlState())
                
                // Set Switch Buttons with Transitabilidad Selected
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
        }
    }
    
    @IBAction func unwindWithSelectedDate(_ segue: UIStoryboardSegue){
        
        if let datePickerController = segue.source as? DatePickerPopoverController{
            if activeDateButton == provisionalDateButton{
                provisionalDate = datePickerController.selectedDate as Date!
                
                // Set Title Button with correct format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                provisionalDateButton.setTitle(dateFormatter.string(from: provisionalDate), for: UIControlState())
            }
            else if activeDateButton == definitivaDateButton{
                definitivaDate = datePickerController.selectedDate as Date!
                
                // Set Title Button with correct format
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                definitivaDateButton.setTitle(dateFormatter.string(from: definitivaDate), for: UIControlState())
            }
            
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        
        let texto : String = textField.text!

        
        if(texto != "" ){
            // Se valida la longitud de 7 caracteres
          // let kmMetrosInicialDouble : String = kmInicialTextField.text!
          //  let kmMetrosFinalDouble : String = kmFinalTextField.text!
            
            
            
          //  let kmMetrosInicialPoint = kmMetrosInicialDouble.stringByReplacingOccurrencesOfString("+", withString: ".")
          //  let kmMetrosInicialDobule : Double = Double(kmMetrosInicialPoint)!
            
           // let kmMetrosFinalPoint = kmMetrosFinalDouble.stringByReplacingOccurrencesOfString("+", withString: ".")
           // let kmMetrosFinalDobule : Double = Double(kmMetrosFinalPoint)!
            
           // print("kmMetrosInicialDobule (\(kmMetrosInicialDobule))")
            
           // print("kmMetrosFinalDobule (\(kmMetrosFinalDobule))")
            
            
            print("El texto de KM (\(texto))")
            
            let longitud = texto.characters.count
            
            if longitud > 7 {
                
                
                let index1 = texto.characters.index(texto.endIndex, offsetBy: -1)
                
                let substring1 = texto.substring(to: index1)
                
                textField.text = substring1
                print("El nuevo texto es: (\(substring1))")
                
            }
        }else{
            textField.text = "000+000"
        }

      
        
    }
    
    func textFieldShouldBeginEditing(_ state: UITextField) -> Bool {
        
        return true
    }
    

    
    
    //TODO transformar a numero
    func textFieldShouldEndEditing(_ kilometros : UITextField) -> Bool {
        
        // Se ejecuta cuando se termina de editar el textField

        print("textFieldShouldEndEditing")

        let fullNameArr = kilometros.text!.components(separatedBy: "+")

        let kmString: String = fullNameArr[0]
        let metrosString: String = fullNameArr[1]
        var kmInicialint:Int = 0
        var  metrosInicialint:Int = 0

        
        if var kmStr : String = kmString {
            if(kmStr == ""){
                kmStr = "0"
            }
            
            kmInicialint = Int(kmStr)!
        }
        
        
        if var metrosStr : String = kmString {
            if(metrosStr == ""){
                metrosStr = "0"
            }
            
            metrosInicialint = Int(metrosStr)!
        }

        if var metrosStr : String = metrosString {
            if(metrosStr.characters.count  > 3){

                let index1End = metrosStr.characters.index(metrosStr.endIndex, offsetBy: -3)
                
                 metrosStr = metrosStr.substring(from: index1End)
                
            }
            if(metrosStr == ""){
                metrosStr = "0"
            }
            metrosInicialint = Int(metrosStr)!
        }
        
        
        if var kmStr : String = kmString {
            if(kmStr.characters.count > 3){
                let index1End = kmStr.characters.index(kmStr.endIndex, offsetBy: -3)
                kmStr = kmStr.substring(from: index1End)
            }
            if(kmStr == ""){
                kmStr = "0"
            }
            
            kmInicialint = Int(kmStr)!
        }       // let kmInicial = (selectedSubtramo?.kmInicial)!
        
        print("El texto de kmString inicial(\(kmString))")
        print("El texto de kmInicialint inicial entero es (\(kmInicialint))")
        

        print("El texto de metrosString inicial(\(metrosString))")
        print("El texto de metrosInicialint inicial(\(metrosInicialint))")

        
        
        print("El texto de kilometros.tag(\(kilometros.tag))")

        
        switch(kilometros.tag){
            case 100:
                kmInicialTextField.text = String(format: "%03d", kmInicialint)+"+"+String(format: "%03d", metrosInicialint)

            break
            
            case 200:
                kmFinalTextField.text = String(format: "%03d", kmInicialint)+"+"+String(format: "%03d", metrosInicialint)

            default: break

        }
        
        
        return true
    }
    

    

    //TODO implementar esta funcion
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if let selectedRange = textField.selectedTextRange {
            
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            
            print("El cursorPosition es \(cursorPosition)")
        }
        
        
        print("El texto del textField es: (\(textField.text))")
        print("El texto shouldChangeCharactersInRange es: (\(range))")
        print("El texto replacementString es: (\(string))")
        print("El range.length es: (\(range.length))")
        print("El range.location es: (\(range.location))")



        

        
        if string == "" && range.length > 0 {
            print("El range.length es: (\(range.length))")

            // Backspace or other deletion
            let stringToNOTDelete = (textField.text! as NSString).substring(with: range)
            print("El stringToDeleteg es: (\(stringToNOTDelete))")

            if stringToNOTDelete == "+" {
                print("NO-bye +")
                
                
                return false
            }
            
        }
        
        
        if range.length==0 && range.location == 3 {
            let arbitraryValue: Int = range.location + 1
            let stringToNOTDelete = (textField.text! as NSString).substring(from: range.location)
            print("El stringToDeleteg es: (\(stringToNOTDelete))")
            if(stringToNOTDelete != ""){
                let firstChar = stringToNOTDelete[stringToNOTDelete.startIndex]
                //let index: Int = distance(text.startIndex, range.startIndex) //will call succ/pred several times
                if firstChar == "+" {
                    
                    if let newPosition = textField.position(from: textField.beginningOfDocument, in: UITextLayoutDirection.right, offset: arbitraryValue) {
                        
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    return false
                    
                    
                }
            }
        }
        
        let aSet = CharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
        
    }
    

    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("Location Manager - DidUpdateLocations:")
        
        if let location = locations.last {
            self.checkTaskRequestsAndDismissPorgress(nil)
            
            print("Latitud: \(location.coordinate.latitude), Longitud: \(location.coordinate.longitude) , Altitud: \(location.altitude)")
            
            latitudeTextField.text = "\(Double(location.coordinate.latitude))"
            longitudeTextField.text = "\(Double(location.coordinate.longitude))"
            altitudeTextField.text = "\(Double(location.altitude))"
            
            // Stop Updating Location
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print("Location Manager - DidChangeAuthorizationStatus: \(status.rawValue)")
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}


// MARK: - PhotoCollectionVC Delegate

extension NewReportVC: PhotosCollectionVCDelegate {
    
    func photosCollectionVCChange(_ photos: [Photo], type: PhotoType) {
        
        switch type{
        case .reporte:
            self.photos =  photos
        case .croquis:
            self.croquisPhotos = photos
        default:
            print("Return Photos without PhotoType")
        }
    }
}



