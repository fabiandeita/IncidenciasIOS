//
//  ConfigurationTableVC.swift
//  Incidencias
//
//  Created by Sebastian on 17/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SVProgressHUD






class ConfigurationTableVC: UITableViewController, UITextFieldDelegate, onResponseApiListener, selectFilter {
    func onReporteE7FetchFinished(responseE7: AnyObject) {
        
    }
    
    func onReporteHistoricoFetchFinished(responseHistorico: AnyObject?) {
        
    }
    
    func onImageEmergenciasFetchFinished(responseImagenes: AnyObject?) {
        
    }
    

    // MARK: Variables
    var reportes = [Reporte]()
    var contadorUpdates : Int = 0
    var contadorUpdatesReceived : Int = 0
    var BIGNUMBER : Int = 150000
    
    
    // MARK: Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    var dataInputs:NSMutableArray = NSMutableArray()
    var reporteIDValidate:Int = Int()
    var currentCatalogTitle: String!
    
    var datosFilter : [String]!
    
    // MARK: LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Core Data Manager Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let arrayData = [String](repeating: "", count: 4)
        HandlerIO.saveFilters(arrayData)
        // Get Reports
        getReports()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload TableView
        self.tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func getReports(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reporte");
        do{
            let objects = try managedObjectContext.fetch(fetchRequest) as! [Reporte]
            print(objects)
            reportes = objects
        } catch {
            print("Fetch failed in Reort, with error: \(error)")
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func saveHost (_ button:UIButton){
        self.view.endEditing(true)
        let filed:UITextField = (dataInputs.object(at: 0) as? UITextField)!
        //print(filed.text)
        let hostsave: String = filed.text!
        HandlerIO.saveHostServices(hostsave, view: self)
        
        print(HandlerIO.getHostServices())
    }
    
    @IBAction func actionFilter(_ button:UIButton){
        print("este es el button \(button)")
    }
    
    func saveHostHard(){
        self.view.endEditing(true)
        let filed:UITextField = (dataInputs.object(at: 0) as? UITextField)!
        //print(filed.text)
        let hostsave: String = filed.text!
        HandlerIO.saveHostServices(hostsave, view: self)
        
        print(HandlerIO.getHostServices())
    }
    
    @IBAction func actionButtonSync(_ sender: AnyObject) {
        
        //saveHost()

        ApiHandler.onResponseApiListenerDelegate = self
        
        ApiHandler.executeEmergenciasCreate(reportes: reportes)


        calculateTotalUpdates()
        
        
        // ApiHandler.executeEmergenciasCreate(reportes)
        
       
       // ApiHandler.sendEmergenciaImagenInfo(reportes[0],responseString: 1391)
        
       // ApiHandler.fetchImagesForAllReports(reportes)
       
        
        if(contadorUpdates > 0){
            SVProgressHUD.show(withStatus: "Enviando reporte(s)...")
        }

    }
    
    
    
    func calculateTotalUpdates(){
        for reporte in reportes{
            let acciones = reporte.acciones?.allObjects as! [Accion]
            let concepts = reporte.conceptos?.allObjects as! [Concepto]
            
            for accion in  acciones {
                let accionesIDValidate =  abs(accion.id as! Int)
                if accionesIDValidate >= BIGNUMBER  {
                    contadorUpdates += 1
                }
                
            }
            
            for concept in concepts{
                let conceptIDValidate =  abs(concept.id as! Int)
                if conceptIDValidate >= BIGNUMBER {
                    contadorUpdates += 1
                }
            }
            
            
             reporteIDValidate =  abs(reporte.reporteId as! Int)
            
            if reporteIDValidate >= BIGNUMBER {
                contadorUpdates += 1
                
            }
            
        }
        
        print("El total de updates esperados es :  \(contadorUpdates)"   )
        
    }
    
    // MARK : onResponseApiListener
    
    
    func onReportFetchFinished(reporte : Reporte) {
        
        self.tableView.reloadData()
        
        contadorUpdatesReceived += 1
        if contadorUpdatesReceived == contadorUpdates{
            print("Se ha terminado las tareas")

            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
            });
            imagesFetch()

        }

    }
    
    
    func  onAccionFetchFinished(accion action : Accion) {
        
        self.tableView.reloadData()

        contadorUpdatesReceived += 1
        
        
        if contadorUpdatesReceived == contadorUpdates{
            print("Se ha terminado las tareas")
            contadorUpdates = 0
            contadorUpdatesReceived = 0
            
            // Hide Progress HUD
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
            });
            imagesFetch()
            self.tableView.reloadData()
        }
    }
    
    
    func onConceptFetchFinished(concepto concept : Concepto) {

        self.tableView.reloadData()
        contadorUpdatesReceived += 1
        
        if contadorUpdatesReceived == contadorUpdates{
            print("Se ha terminado las tareas")
            contadorUpdates = 0
            contadorUpdatesReceived = 0
            
            // Hide Progress HUD
            DispatchQueue.main.async(execute: {
                SVProgressHUD.dismiss()
            });
            imagesFetch()

            self.tableView.reloadData()
        }
    }
    
    func onImageReportFetchFinished(concepto concept : Concepto){
        
    }

    func  imagesFetch(){
       // getReports();
        ApiHandler.fetchImagesForAllReports(reportes: reportes)

        ApiHandler.fetchImagesForAllConcepts(reportes: reportes)
        
        ApiHandler.fetchCroquisForAllReports(reportes: reportes)
        
         self.tableView.reloadData()
        
        usleep(10000);

    }
    

    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else if section == 1{
            return 1
        }
        
        return reportes.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Static Cell will be shown in a second row
        if (indexPath as NSIndexPath).section == 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cellConfig") as! ConfigIPCell!
            if cell == nil {
                tableView.register(UINib(nibName: "ConfigIPCell", bundle: nil), forCellReuseIdentifier: "cellConfig")
                cell = tableView.dequeueReusableCell(withIdentifier: "cellConfig") as! ConfigIPCell!
                cell?.labelText.text = "Host de Servicios:"
                cell?.input.delegate = self
                //.addTarget(self, action: #selector(logoAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell?.saveButton.addTarget(self, action: #selector(ConfigurationTableVC.saveHost(_:)), for: .touchUpInside)
                cell?.input.tag = (indexPath as NSIndexPath).row
                cell?.input.text =  HandlerIO.getHostServices()
                dataInputs.add(cell?.input)
            }
            
            return cell!
        }else if (indexPath as NSIndexPath).section == 1{
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "CELL") as UITableViewCell!
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CELL")
                cell?.backgroundColor = UIColor.red
                cell?.textLabel?.text = "Filtrar"
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.textColor = UIColor.white
                cell?.selectionStyle = .none
            }
            
           /* var cell = tableView.dequeueReusableCellWithIdentifier("StaticCell") as! UpdateSelectionReportViewCell!
            if cell == nil {
                tableView.registerNib(UINib(nibName: "StaticTableViewCell", bundle: nil), forCellReuseIdentifier: "StaticCell")
                cell = tableView.dequeueReusableCellWithIdentifier("StaticCell") as! UpdateSelectionReportViewCell!
                cell.view = self
                cell.filterDelegate = self
            }*/
            
            
            
            return cell!
        }
        else{
            
            //reportUpdateCell
            var cell = tableView.dequeueReusableCell(withIdentifier: "updateCell") as! reportUpdateCell!
            
            
            if cell == nil {
                tableView.register(UINib(nibName: "reportUpdateCell", bundle: nil), forCellReuseIdentifier: "updateCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "updateCell") as! reportUpdateCell!
                cell?.selectionStyle = .none
            }
            
           // let cell = tableView.dequeueReusableCellWithIdentifier("DynamicCell", forIndexPath: indexPath)
            
            // Set Cell
            let report = reportes[(indexPath as NSIndexPath).row]
            cell?.statusImage.layer.cornerRadius = (cell?.statusImage.frame.size.width)! / 2;
            cell?.statusImage.clipsToBounds = true;
            print("\(report.reporteId ) \(report.hasBeedModified)")
            if abs(report.reporteId!.intValue) >= BIGNUMBER || report.hasBeedModified == true {
                cell?.statusImage.backgroundColor = UIColor.yellow
            }else{
                cell?.statusImage.backgroundColor = UIColor.green
            }
           // cell.textLabel!.text = "\(report.reporteId!.integerValue)"
            cell?.idCell.text = "\(report.reporteId!.intValue)"
            cell?.descripcionCell.text = report.descripcion!
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == 0 {
            return 44
        }else if (indexPath as NSIndexPath).section == 1 {
            return 44
        }
        
        return 50
    }
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath){
        
        if (indexPath as NSIndexPath).section == 1{
            
            DispatchQueue.main.async {
                do {
                     self.performSegue(withIdentifier: "ShowFilterPopover2", sender: self)
                }
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //MARK: UITextFeld Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        saveHostHard()
        return true
    }
    
    func filterwithButton(_ object: [NSManagedObject]) {
        print("este es el objeto para filtro")
        self.performSegue(withIdentifier: "2ShowCatalogFromFilter", sender: object)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowFilterPopover2"{
            print("Entra aca")
            HandlerIO.saveFiltersBool(false)
            // Set Popover: iPhone needs this change to show as Popover
            let navController = segue.destination as! UINavigationController
            if let popover = navController.popoverPresentationController {
                print("Validacion de popOver")
                popover.delegate = self
            }
        }
    }
    
    func filters(_ data:[String]){
        
        
        var reporteFilter = [Reporte]()
        
        if  data[0] != ""{
            reporteFilter = filtersData(0, data: data, toFilter: getInitialReport())
            if data[1] != "" {
                reporteFilter = filtersData(1, data: data, toFilter: reporteFilter)
                if data[2] != "" {
                    reporteFilter = filtersData(2, data: data, toFilter: reporteFilter)
                    if data[3] != "" {
                        reporteFilter = filtersData(3, data: data, toFilter: reporteFilter)
                    }
                }
            }
        }else{
            reporteFilter = getInitialReport()
        }
        self.reportes = reporteFilter
        self.tableView.reloadData()
    }
    
    func getInitialReport() -> [Reporte]{
        let reports = HandlerIO.getReports()
        return reports!
    }
    
    
    func filtersData(_ position:Int, data:[String], toFilter:[Reporte]) -> [Reporte] {
        var reporteFilter = [Reporte]()
        
        switch position {
        case 0:
            for entidad in toFilter{
                if entidad.entidadFederativa?.nombre == data[0]{
                    reporteFilter.append(entidad)
                }
            }
            break
        case 1:
            for entidad in toFilter{
                if entidad.carretera?.nombre == data[1]{
                    reporteFilter.append(entidad)
                }
            }
            break
        case 2:
            for entidad in toFilter{
                if entidad.tramo?.nombre == data[2]{
                    reporteFilter.append(entidad)
                }
            }
            break
        case 3:
            for entidad in toFilter{
                if entidad.subtramo?.nombre == data[3]{
                    reporteFilter.append(entidad)
                }
            }
            break
        default:
            break
        }
        return reporteFilter
    }
    @IBAction func unwind2SelectedFilter(_ segue: UIStoryboardSegue){
        print("unwindSelectedFilter")
        if let catalogController = segue.source as? FilterPopoverController{
            print("datos esen confuration \(catalogController.arrayData)")
            filters(catalogController.arrayData)
        }
    }

}

// MARK: - UIPopoverPresentationControllerDelegate

extension ConfigurationTableVC: UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
