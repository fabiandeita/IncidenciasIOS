//
//  ReportDetailTableVC.swift
//  Incidencias
//
//  Created by Sebastian TC on 10/23/15.
//  Copyright © 2015 PICIE. All rights reserved.
//


import UIKit
import SVProgressHUD
class ReportDetailTableVC: UITableViewController , onResponseApiListener{
    
    
    //Folio
    @IBOutlet var foliotxt: UILabel!
    //Ubicacion
    @IBOutlet var entidadText: UILabel!
    @IBOutlet var carrtera: UILabel!
    @IBOutlet var tramo: UILabel!
    @IBOutlet var subTramo: UILabel!
    
    //Geolocalizacion
    @IBOutlet var kminicial: UILabel!
    @IBOutlet var kmFinal: UILabel!
    @IBOutlet var latitud: UILabel!
    @IBOutlet var longitud: UILabel!
    @IBOutlet var altitud: UILabel!
    
    //Descripcion
    @IBOutlet var descrip: UILabel!
    
    //Tipos de Daño
    @IBOutlet var dañosCausados: UILabel!
    @IBOutlet var causa: UILabel!
    @IBOutlet var tipoInci: UILabel!
    @IBOutlet var categoria: UILabel!
    
    //Transito
    @IBOutlet var optionTransito: UILabel!
    @IBOutlet var pasoVehiculos: UILabel!
    @IBOutlet var rutaAlter: UILabel!
    @IBOutlet var accionesRe: UILabel!
    
    //Fecha
    @IBOutlet var provisionalFecha: UILabel!
    @IBOutlet var definitiva: UILabel!
    
    //Conceptos
    
    var folio : Int = 0
    
    @IBOutlet var ReportDetailTableVC: UITableView!
    
    
    // Imagenes
    var imagenesList : NSArray?
    
    
    //Variables
    var dataEmergencia : NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("report Detail")
       // print("Datos en Detalle \(dataEmergencia)")
        setData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(){
        folio  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey :"emergenciaid")as! Int
        foliotxt.text = "\(folio)"
        
        entidadText.text = (((dataEmergencia.value(forKey : "emergencia") as AnyObject).value(forKey : "subtramo") as AnyObject).value(forKey :"entidadfederativa") as AnyObject).value(forKey : "nombre") as! String!
        
        //TODO REVISAR ESTE
        
        
        
        if let origen = ((((dataEmergencia.value(forKey :"emergencia") as
            AnyObject).value(forKey : "subtramo") as AnyObject).value(forKey : "tramo") as AnyObject).value(forKey : "carretera") as AnyObject).value(forKey : "origen") as! String!
        {
            
            if let destino = ((((dataEmergencia.value(forKey :"emergencia") as
                AnyObject).value(forKey : "subtramo") as AnyObject).value(forKey : "tramo") as AnyObject).value(forKey : "carretera") as AnyObject).value(forKey : "destino") as! String!
            {
                carrtera.text = "\(origen)"+" - "+"\(destino)"
            }
        }
        
        
        if let origen = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "origen") as! String!
        {
            
            if let destino = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "destino") as! String!
            {
                tramo.text = "\(origen)"+" - "+"\(destino)"
            }
        }
        
        
        if let origen = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "origen") as! String!
        {
            
            if let destino = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "destino") as! String!
            {
                subTramo.text = "\(origen)"+" - "+"\(destino)"
                kminicial.text = "\(origen)"
                kmFinal.text =  "\(destino)"
                
                
            }
        }
        
        
        // TODO implementar mascara
        //Geolocalizacion
        let inicial : String = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "kminicialString"))! as! String
        
        
        let final : String = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "kmfinalString"))! as! String
        
        
        
        
        
        
        kminicial.text = inicial
        kmFinal.text  = final
        
        
        
        
        
        
        let lat : NSNumber = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "latitud") as! NSNumber!
        
        latitud.text =  "\(lat)"
        
        let lon : NSNumber = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "longitud") as! NSNumber!
        
        longitud.text =  "\(lon)"
        
        let alt : NSNumber = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey:"altitud") as! NSNumber!
        
        altitud.text =  "\(alt)"
        
        
        //Descripcion
        descrip.text = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "descripcion") as! String!
        //descrip.adjustsFontSizeToFitWidth = true
        
        //Tipos Daño
        dañosCausados.text = ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey : "dano") as AnyObject).value(forKey :"nombre") as! String!
        
        //Transito
        pasoVehiculos.text = PasoVehiculos()
        let altern  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "rutaalternativa") as! Int!
        
        if altern == 1 {
            rutaAlter.text = "SI"
        }else{
            rutaAlter.text = "No"
        }
        
        accionesRe.text = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "accionesrealizadas") as! String!
        if nullToNil(value :((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "fechaProvisionalDate") as AnyObject)) != nil{
            let fechaPro : Double = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "fechaProvisionalDate") as! Double!
            print("fechaProvisionalDate \(fechaPro)");
            
            provisionalFecha.text = fechaString(timeIs: fechaPro)
        }else{
            provisionalFecha.text = "N/A"
        }
        
        if nullToNil(value: ((dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "fechaDefinitivaDate") as AnyObject)) != nil{
            let defiDate : Double = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "fechaDefinitivaDate") as! Double!
            print("fechaDefinitivaDate \(defiDate)");
            definitiva.text = fechaString(timeIs: defiDate)
        }else{
            definitiva.text = "N/A"
        }
        
        
        
        
    }
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
    
    func fechaString(timeIs:Double)->String{
        
        if let theDate = Date(jsonDate: "/Date(\(timeIs))/") {
            let dateFormatterService = DateFormatter()
            dateFormatterService.dateFormat = "yyyy-MM-dd"//"M/d/yyyy h:mm:ss a"
            
            
            
            return dateFormatterService.string(from: theDate)
        } else {
            return "N/A"
        }
        
    }
    
    func PasoVehiculos() ->String{
        var paso: String = ""
        
        // TRANS Los valores obtenidos son:  0     Nulo
        // TRANS Los valores obtenidos son:  1     Total
        // TRANS Los valores obtenidos son:  2     Provisional
        // TRANS Los valores obtenidos son:  3     Parcial
        
        let transito  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "transito") as! Int!
        
        let autos  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "vehiculostransitanautos") as! Int!
        let camiones  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "vehiculostransitancamiones") as! Int!
        let todos  = (dataEmergencia.value(forKey: "emergencia") as AnyObject).value(forKey: "vehiculostransitantodotipo") as! Int!
        
        
        switch transito {
        case 0?:
            paso = "NULO->  "
        case 1?:
            paso = "TOTAL->  "
        case 2?:
            paso = "PROVISIONAL->  "
        case 3?:
            paso = "PARCIAL->  "
        default:
            paso = "N/A  "
            
        }
        if autos == 1{
            paso = paso + "-Autos "
        }
        if camiones == 1{
            paso = paso + "-Camiones "
        }
        if todos == 1{
            paso = paso + "-Todos "
        }
        
        return paso
    }
    
    @IBAction func viewDetailE7(sender: AnyObject) {
        
    }
    
    
    @IBAction func viewDetailHistory(sender: AnyObject) {
        
    }
    
    
    @IBAction func verImagenesEmergencia(_ sender: Any) {
        ApiHandler.onResponseApiListenerDelegate = self
        SVProgressHUD.show(withStatus: "Consultando imagenes de la incidencia")
        
        ApiHandler.getImagenesEmergencia(id: folio)
    }
 
    
    
    func onReportFetchFinished(reporte : Reporte){
        
    }
    func onAccionFetchFinished(accion: Accion){
        
    }
    func onConceptFetchFinished(concepto: Concepto){
        
    }
    func onImageReportFetchFinished(concepto: Concepto){
        
    }
    func onReporteE7FetchFinished(responseE7: AnyObject){
        
    }
    func onReporteHistoricoFetchFinished(responseHistorico: AnyObject?){
        
    }
    
    func onImageEmergenciasFetchFinished(responseImagenes: AnyObject?) {
        SVProgressHUD.dismiss()
        
        if let json = responseImagenes{
            if let rootDict = json as? NSDictionary{
                let success = rootDict["success"] as! Int
                var total = rootDict["total"] as! Int
                imagenesList = rootDict["data"] as! NSArray
              //  print("Total de reportes \(total) \n")
                
             //   self.performSegue(withIdentifier: "showImagesEmergencia", sender: imagenesList)
                
                
                if total == 0{
                    self.showSimpleAlert(title: "Aviso", message: "No se encontraron reportes\n con esos parametros")
                }else{
                    self.performSegue(withIdentifier: "showImagesEmergencia", sender: imagenesList)
                    //self.performSegueWithIdentifier("DetailReport", sender: dataArray)
                    //conceptosArray = dataArray
                    //totalConceptos = total
                    //tableView.delegate = self
                    //tableView.dataSource = self
                    //tableView.reloadData()
                    
                }
                
                if success != 1{
                    self.showSimpleAlert(title: "Aviso", message: "No se encontraron reportes\n con esos parametros")
                }
                
            }
            
            
        }
        else{
             self.showSimpleAlert(title: "Aviso", message: "Error intente mas tarde")
        }
    }
    
    //Mark Navigtion
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        
        if segue.identifier == "verE7Segue"{
            let detailConceptosVC = segue.destination as! DetailConceptosVC
            
            detailConceptosVC.sectionReport = 0
            detailConceptosVC.isE7orHistoricReport = 1
            detailConceptosVC.emergenciaId = folio
            
        } else if segue.identifier == "verHistoricoSegue"{
            let detailConceptosVC = segue.destination as! DetailConceptosVC
            
            detailConceptosVC.sectionReport = 1
            detailConceptosVC.isE7orHistoricReport = 0
            detailConceptosVC.emergenciaId = folio
        } else if segue.identifier == "showImagesEmergencia"{
           // let nav = segue.destination as! UINavigationController
            let reporteImagenesListVC = segue.destination as! ReporteImagenesListVC
          //  let reporteImagenesListVC = nav.topViewController as! ReporteImagenesListVC
            reporteImagenesListVC.imagenesList = self.imagenesList
            
            
        }
        
    }
    
    
    // MARK: Private Methods
    
    private func showSimpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

