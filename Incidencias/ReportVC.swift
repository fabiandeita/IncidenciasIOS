//
//  ReportVC.swift
//  Incidencias
//
//  Created by VaD on 25/01/16.
//  Copyright © 2016 PICIE. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SVProgressHUD
import CoreData

// Enum State Connection
enum ConnectionState2 {
    
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

class ReportVC: UIViewController,UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    // MARK: - IBOUtlets
    // Buttons
    @IBOutlet var entidadButton: UIButton!
    @IBOutlet var carreteraButton: UIButton!
    @IBOutlet var tramoButton: UIButton!
    @IBOutlet var subtramoButton: UIButton!
    @IBOutlet var danosButton: UIButton!
    @IBOutlet var causasButton: UIButton!
    @IBOutlet var tiposButton: UIButton!
    @IBOutlet var transitabilidadButton: UIButton!
    @IBOutlet var fechaButton: UIButton!
    @IBOutlet var fechaHastaButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewContainButtons: UIView!
    
    // MARK: - Variables
    var currentCatalogTitle: String!
    var currentButton: UIButton!
    let transitabilidadDict = [0: "Provisional", 1: "Parcial", 2: "Total", 3: "Nulo"]
    var numberTramosReqest = 0;
    var connectionState: ConnectionState = .close
    var provisionalDate: NSDate!
    var provisionalDateHasta: NSDate!
    var datosReport :NSMutableArray = NSMutableArray()
    var objetosEntidades2 :NSMutableArray = NSMutableArray()
    var objetosEntidadesDB2 :NSMutableArray = NSMutableArray()
    var dataEntidades2 :NSMutableArray = NSMutableArray()
    var datosReportDict :NSMutableDictionary = NSMutableDictionary()
    var alamofireManager : Alamofire.SessionManager?
    var isHasta : Bool = false
    
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
    var alamoFireManager : Alamofire.SessionManager?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Core Data Manager Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        let configuration = URLSessionConfiguration.default

        configuration.timeoutIntervalForRequest = 160 // seconds
        configuration.timeoutIntervalForResource = 160
        self.alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        
        
       getCatalogs()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

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
                                }
                            }
                        }
                    }
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
    
    fileprivate func downloadCatalogCarreteras(){
        print("Downloading Catalogs Carreteras")
        showProgressWithStatus("Descargando Carreteras...")
        
        connectionState = .downloadCarreteras
        for entidad in entidadesArray {
            Alamofire.request("\(URL_SERVICES)\(SERVICIO_CARRETERAS)", method: .get,  parameters: ["entidadid": entidad.id.intValue])
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
            Alamofire.request("\(URL_SERVICES)\(SERVICIO_TRAMOS)", method: .get, parameters: parameters)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        //print("Download Tramos by Carretera(\(carretera.id)) ERROR: \(error.userInfo)")
                        print("Download Tramos by Carretera(\(carretera.id)) ERROR")
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
        }
    }
    
    fileprivate func downloadCatalogSubtramos(_ tramos: [Tramo]){
        print("Downloading Catalog Subtramos")
        showProgressWithStatus("Descargando Subtramos...")
        
        connectionState = .downloadSubtramos
        for tramo in tramos {
            let parameters = ["tramoid": tramo.id.intValue, "entidadid": tramo.carretera.entidadFederativa.id.intValue]
            Alamofire.request("\(URL_SERVICES)\(SERVICIO_SUBTRAMOS)",method: .get, parameters: parameters)
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Subtramos by Tramo(\(tramo.id)) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        
                        
                        if let rootDict = response.result.value as? NSDictionary {
                            print("Download Subtramos by Tramo(\(tramo.id)) SUCCESS")
                            //print("JSON Subtramos: \(rootDict)")
                            
                            // Array of "Subtramos"
                            if let subtramos = rootDict["data"] as? [NSDictionary] {
                                //print("Subtramos: \(subtramos)")
                                
                                // Save "Subtramos" in DB
                                for subtramoDict in subtramos {
                                    
                                    // Create new Subtramo
                                    let description = NSEntityDescription.entity(forEntityName: "Subtramo", in: self.managedObjectContext)!
                                    let subtramo = Subtramo(entity: description, insertInto: self.managedObjectContext)
                                    
                                    // Set Attributes
                                    subtramo.id =  subtramoDict["id"] as! NSNumber
                                    subtramo.nombre =  subtramoDict["nombre"] as! String
                                    subtramo.kmFinal =  subtramoDict["kmfinal"] as! NSNumber
                                    subtramo.kmFinal = subtramoDict["kmfinal"] as! NSNumber
                                    subtramo.tramo = tramo
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
    
    fileprivate func downloadCatalogDanos(){
        print("Downloading Catalog Daños")
        showProgressWithStatus("Descargando Daños...")
        
        connectionState = .downloadDanos
        Alamofire.request( "\(URL_SERVICES)\(SERVICIO_DANOS)",method: .get)
            .responseJSON { response in
                
                if let error = response.result.error {
                    print("Download Daños ERROR: \(error.localizedDescription)")
                    self.checkTaskRequestsAndDismissPorgress(error as NSError)
                    
                }else{
                    
                    
                    if let rootDict = response.result.value as? NSDictionary {
                        print("Download Daños SUCCESS")
                        
                        // Array of "Danos"
                        if let danos = rootDict["data"] as? [NSDictionary] {
                            //print("Daños: \(danos)")
                            
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
        Alamofire.request( "\(URL_SERVICES)\(SERVICIO_CAUSAS)",method: .get)
            .responseJSON { response in
                
                if let error = response.result.error {
                    print("Download Causas ERROR: \(error.localizedDescription)")
                    self.checkTaskRequestsAndDismissPorgress(error as NSError)
                    
                }else{
                    
                    
                    if let rootDict = response.result.value as? NSDictionary {
                        print("Download Causas SUCCESS")
                        
                        // Array of "Causas"
                        if let causas = rootDict["data"] as? [NSDictionary] {
                            //print("Causas: \(causas)")
                            
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
            Alamofire.request( "\(URL_SERVICES)\(SERVICIO_TIPOS)",method: .get, parameters: ["causaid": causa.id.intValue])
                .responseJSON { response in
                    
                    if let error = response.result.error {
                        print("Download Tipos by Causa(\(causa.id.intValue)) ERROR: \(error.localizedDescription)")
                        self.checkTaskRequestsAndDismissPorgress(error as NSError)
                        
                    }else{
                        
                        
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
        }
    }
    fileprivate func downloadCatalogCategorias(_ tipos: [TipoEmergencia]){
        print("Downloading Catalog Categorias")
        showProgressWithStatus("Descargando Categorías...")
        
        connectionState = .downloadCategorias
        for tipo in tipos{
            Alamofire.request( "\(URL_SERVICES)\(SERVICIO_CATEGORIAS)", method: .get, parameters: ["tipoid": tipo.id.intValue])
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
                        self.getCatalogs()
                    })
                    
                    
                case .downloadCausas:
                    print("END Download all Causas")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getCatalogs()
                    })
                    
                    
                case .downloadTipos:
                    print("END Download all Tipos")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getCatalogs()
                    })
                    
                    
                case .downloadCategorias:
                    print("END Download all Categorías")
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.getCatalogs()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Set Catalog Popover Controller
        if segue.identifier == "ShowPopoverReport" {
            let navController = segue.destination as! UINavigationController
            
            // Set Controller
            let catalogController = navController.viewControllers[0] as! CatalogPopoverController
            if currentButton == entidadButton{
                catalogController.isMultiSelect = true
                if objetosEntidades2.count != 0{
                    catalogController.objetosEntidades = objetosEntidades2
                    catalogController.objetosEntidadesDB = objetosEntidadesDB2
                    catalogController.dataEntidades = dataEntidades2
                }else{
                    
                }
            }else{
                catalogController.isMultiSelect = false
            }
            catalogController.segueType = .popoverReport
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
        }else if segue.identifier == "ShowDatePickerPopover2"{
            let navController = segue.destination as! UINavigationController
            
            // Set Controller
            let datePickerController = navController.viewControllers[0] as! DatePickerPopoverController
            datePickerController.segueType = 1
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
        }else if segue.identifier == "DetailReport"{
            
            let navController = segue.destination as! ReportsTableVC
            navController.datosReporte = sender as? NSArray
            // Set Controller
            
            
        }
    }
    @IBAction func dateShow(_ sender: UIButton) {
        
        if sender == fechaButton{
            isHasta = false
            currentCatalogTitle = "Fecha de Consulta"
            currentButton = fechaButton
            self.performSegue(withIdentifier: "ShowDatePickerPopover2", sender: sender)
        }else{
            isHasta = true
            currentCatalogTitle = "Fecha Hasta"
            currentButton = fechaHastaButton
            self.performSegue(withIdentifier: "ShowDatePickerPopover2", sender: sender)
        }
        
    }

    @IBAction func actionButtonCatalog(_ sender: UIButton) {
        
        var object = [NSManagedObject]()
        
        // Set Catalog Title
        switch sender{
            
            // Cases of "Datos de Ubicación"
        case entidadButton:
            
            if entidadesArray.isEmpty{
                print("entidad Array is Empity")
                Utilities.showAlertWhenLackCatalogsInController(self)
                return
            }
            
            currentCatalogTitle = "Entidades"
            currentButton = entidadButton
            object = entidadesArray
            
        case carreteraButton:
            
            
            if selectedEntidad == nil {
              //  Utilities.showAlertWhenLackCatalogsInController(self)
                Utilities.showSimpleAlertControllerMessage("Seleccione primero Entidad", inController: self)
                return
            }else if (objetosEntidades2.count>1){
                // objetosEntidades
                Utilities.showAlertWhenMultipleEntitiesSelectedInController(controller: self)
                
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
            
            // Case of "Transitabilidad"
        case transitabilidadButton:
            currentCatalogTitle = "Transitabilidad"
            currentButton = transitabilidadButton
            object = transitabilidadesArray
            
            
            
        default:
            print("Selected any other button that is not Catalog")
        }
        
        // Show Popover
        self.performSegue(withIdentifier: "ShowPopoverReport", sender: object)
    }
    @IBAction func unwindWithSelectedItem2(_ segue: UIStoryboardSegue){
        
        // Get Item Selected
        if let catalogController = segue.source as? CatalogPopoverController {
            //print("Item Selected: \(catalogController.selectedItem)")
            
            // Set values
            print("catalogo \(catalogController.selectedObject)")
            if let object = catalogController.selectedObject as? EntidadFederativa {

                //entidadButton.setTitle(defaultButtonTitle, for: UIControlState())
                if object != selectedEntidad {
                    
                    selectedEntidad = object
                   // print(selectedEntidad?.valueForKey("id") as! Int)
                    carreterasArray = selectedEntidad?.carreteras?.allObjects as! [Carretera]
                    entidadButton.setTitle(selectedEntidad?.nombre, for: UIControlState())


                    
                   datosReport.add(selectedEntidad?.value(forKey: "id") as! Int)
                    objetosEntidades2 = catalogController.objetosEntidades
                    objetosEntidadesDB2 = catalogController.objetosEntidadesDB
                    dataEntidades2 = catalogController.dataEntidades
                    datosReportDict.setValue(catalogController.objetosEntidades, forKey: "selectedEntidades")
                    
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
                    datosReportDict.setValue(selectedCarretera?.value(forKey: "id") as! Int, forKey: "idCarretera")
                    //datosReport.addObject(selectedCarretera?.valueForKey("id") as! Int)
                    
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
                    subtramosArray = selectedTramo?.subtramos.allObjects as! [Subtramo]
                    
                    datosReportDict.setValue(selectedTramo?.value(forKey: "id") as! Int, forKey: "idTramo")
                    
                    //datosReport.addObject(selectedTramo?.valueForKey("id") as! Int)
                    
                    // Set Other Default Values in Cascade
                    selectedSubtramo = nil
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
            }
            else if let object = catalogController.selectedObject as? Subtramo {
                selectedSubtramo = object
                subtramoButton.setTitle(selectedSubtramo?.nombre, for: UIControlState())
                
                datosReportDict.setValue(selectedSubtramo?.value(forKey: "id") as! Int, forKey: "idSubtramo")
               // datosReport.addObject(selectedSubtramo?.valueForKey("id") as! Int)
            }
            else if let object = catalogController.selectedObject as? Dano{
                selectedDano = object
                danosButton.setTitle(selectedDano?.nombre, for: UIControlState())
                
                datosReportDict.setValue(selectedDano?.value(forKey: "id") as! Int, forKey: "danos")
                //datosReport.addObject(selectedDano?.valueForKey("id") as! Int)
            }
            else if let object = catalogController.selectedObject as? CausaEmergencia{
                
                if object != selectedCausa{
                    
                    selectedCausa = object
                    causasButton.setTitle(selectedCausa?.nombre, for: UIControlState())
                    tiposArray = selectedCausa?.tipoEmergencias?.allObjects as! [TipoEmergencia]
                    datosReportDict.setValue(selectedCausa?.value(forKey: "id") as! Int, forKey: "causa")
                   // datosReport.addObject(selectedCausa?.valueForKey("id") as! Int)
                    
                    // Set Other Default Values in Cascade
                    selectedTipo = nil
                    tiposButton.setTitle(defaultButtonTitle, for: UIControlState())
                    selectedCategoria = nil
                    categoriasArray.removeAll()
                }
                
            }
            else if let object = catalogController.selectedObject as? TipoEmergencia{
                
                if object != selectedTipo {
                    
                    selectedTipo = object
                    tiposButton.setTitle(selectedTipo?.nombre, for: UIControlState())
                    categoriasArray = selectedTipo?.categoriaEmergencias?.allObjects as! [CategoriaEmergencia]
                    
                    datosReportDict.setValue(selectedTipo?.value(forKey: "id") as! Int, forKey: "tipoEmergencia")
                    //datosReport.addObject(selectedTipo?.valueForKey("id") as! Int)
                    // Set Other Default Values in Cascade
                    selectedCategoria = nil
                }
            }
            else if let object = catalogController.selectedObject as? CategoriaEmergencia{
                selectedCategoria = object
            }
            else if let object = catalogController.selectedObject as? Transitabilidad{
                selectedTransitabilidad = object
                transitabilidadButton.setTitle(selectedTransitabilidad?.nombre, for: UIControlState())
                datosReportDict.setValue(selectedTransitabilidad?.value(forKey: "id") as! Int, forKey: "transito")
               // datosReport.addObject(selectedTransitabilidad?.valueForKey("id") as! Int)
                
                // Set Switch Buttons with Transitabilidad Selected
            }else{
                selectedEntidad = nil
                carreterasArray.removeAll()
                entidadButton.setTitle(defaultButtonTitle, for: UIControlState())

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
    }
    @IBAction func unwindReportDate(_ segue: UIStoryboardSegue){
        
        if let datePickerController = segue.source as? DatePickerPopoverController{
           
            
            
            // Set Title Button with correct format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if isHasta == false{
                provisionalDate = datePickerController.selectedDate as Date! as! NSDate
                fechaButton.setTitle(dateFormatter.string(from: provisionalDate as Date), for: UIControlState())
                
                let dateFormatterService = DateFormatter()
                dateFormatterService.dateFormat = "yyyy-MM-dd HH:mm:ss"//"M/d/yyyy h:mm:ss a"
                datosReportDict.setValue(dateFormatterService.string(from: provisionalDate as Date), forKey: "fechaConsultade")
            }else{
                provisionalDateHasta = datePickerController.selectedDate as! NSDate
                fechaHastaButton.setTitle(dateFormatter.string(from: provisionalDateHasta as Date), for: UIControlState())
                
                let dateFormatterService = DateFormatter()
                dateFormatterService.dateFormat = "yyyy-MM-dd HH:mm:ss"//"M/d/yyyy h:mm:ss a"
                datosReportDict.setValue(dateFormatterService.string(from: provisionalDateHasta as Date), forKey: "fechaConsultaAl")
            }
            
            
           // datosReport.addObject(dateFormatter.stringFromDate(provisionalDate))
            
        }
    }
    
    @IBAction func Continuar(_ sender: UIButton) {
        //print("\nDatos Report a mamndar \(datosReportDict)\n")
        datosReportDict.setValue(0, forKey: "idEstado")
        datosReportDict.setValue(0, forKey: "recursos")
        datosReportDict.setValue("", forKey: "error")
        sendWS("http://\(HandlerIO.getHostServices())/EmergenciasWS/web/Report_view.action", postRequest: datosReportDict)
    }
    
    func sendWS(_ url:String,postRequest:NSMutableDictionary){
    
        
        
        
        print(postRequest, terminator: "")
        
        var error: NSError?
        
        var JSON: NSString!
        let diccc :NSDictionary = postRequest
        do{
            let theJSONData = try JSONSerialization.data(withJSONObject: diccc, options: JSONSerialization.WritingOptions())

            JSON = NSString(data: theJSONData, encoding: String.Encoding.utf8.rawValue)
        } catch let error1 as NSError {
            error = error1
        }
        
    
        
        let data1 = ["data1": JSON] as Parameters
       //print("Data: \(data1)")
        print (url)
        SVProgressHUD.show(withStatus: "Buscando reportes")
        alamoFireManager!.request( url as URLConvertible , method: .post,parameters:data1)
            .responseJSON { response in
                SVProgressHUD.dismiss()
                if let error = response.result.error {
                    print("Emergencia Create ERROR: \(error.localizedDescription)")
                    self.showSimpleAlert("Aviso", message: "A ocurrido un error intente mas tarde")
                }else{
                   // print("Response JSON: \(response.result.value!)")
                    if let json = response.result.value{
                        if let rootDict = json as? NSDictionary{
                            let success = rootDict["success"] as! Int
                            let total = rootDict["total"] as! Int
                            let dataArray = rootDict["data"] as! NSArray
                           // print("Total de reportes \(total) \n")
                            
                            if total == 0{
                                self.showSimpleAlert("Aviso", message: "No se encontraron reportes\n con esos parametros")
                            }else{
                                self.performSegue(withIdentifier: "DetailReport", sender: dataArray)
                            }
                            
                            if success != 1{
                                self.showSimpleAlert("Aviso", message: "No se encontraron reportes\n con esos parametros")
                            }
                        }
                    }
                    // Save Reporte ID (emergenciaid)
                }
        }
        
    }
    fileprivate func showSimpleAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearInputs(_ sender: UIBarButtonItem) {
        
        print("Limpiar campos")
        datosReportDict.removeAllObjects()
        
        for view in self.viewContainButtons.subviews {
            if let btn = view as? UIButton {
                if btn == entidadButton{
                    
                    selectedEntidad = nil
                    carreterasArray.removeAll()
                    entidadButton.setTitle(defaultButtonTitle, for: UIControlState())
                    
                    
                    datosReport.removeAllObjects()
                    objetosEntidades2.removeAllObjects()
                    objetosEntidadesDB2.removeAllObjects()
                    dataEntidades2.removeAllObjects()
                }else if btn == carreteraButton{
                    selectedCarretera = nil
                    tramosArray.removeAll()
                    carreteraButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == tramoButton{
                    selectedTramo = nil
                    tramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                    subtramosArray.removeAll()
                }else if btn == subtramoButton{
                    selectedSubtramo = nil
                    subtramoButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == danosButton{
                    selectedDano = nil
                    danosButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == causasButton{
                    selectedCausa = nil
                    tiposArray.removeAll()
                    causasButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == tiposButton{
                    selectedTipo = nil
                    tiposButton.setTitle(defaultButtonTitle, for: UIControlState())
                    categoriasArray.removeAll()
                }else if btn == transitabilidadButton{
                    selectedTransitabilidad = nil
                    transitabilidadButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == fechaButton{
                    fechaButton.setTitle(defaultButtonTitle, for: UIControlState())
                }else if btn == fechaHastaButton{
                    fechaHastaButton.setTitle(defaultButtonTitle, for: UIControlState())
                }
                
            }
        }
        
    }
}
