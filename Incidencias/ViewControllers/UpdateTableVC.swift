//
//  UpdateTableVC.swift
//  Incidencias
//
//  Created by Sebastian on 09/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData

class UpdateTableVC: UITableViewController{
    
    // MARK: - Variables
    var reports = [Reporte]()
    var datosFilter : [String]!
    
    // MARK: - Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Estas en esta vista")
        
        // Get Core Data Manager Context
        //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //managedObjectContext = appDelegate.managedObjectContext
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let arrayData = [String](repeating: "", count: 4)
        HandlerIO.saveFilters(arrayData)
        
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = false
        
        // Get Reports
        if let reports = HandlerIO.getReports(){
            self.reports = reports
            self.tableView.reloadData()
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
        self.reports = reporteFilter
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
    
    
    // MARK: - UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return reports.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Set Cell
        let report = reports[(indexPath as NSIndexPath).section]
        
        
        if (indexPath as NSIndexPath).row == 0{
            // Get "Acciones"
            let acciones = report.acciones?.allObjects as! [Accion]
            cell.textLabel?.text = "Acciones:"
            cell.detailTextLabel?.text = "\(acciones.count)"
        }
        else if (indexPath as NSIndexPath).row == 1{
            // Get "Conceptos"
            let conceptos = report.conceptos?.allObjects as! [Concepto]
            cell.textLabel?.text = "Conceptos:"
            cell.detailTextLabel?.text = "\(conceptos.count)"
        } else if (indexPath as NSIndexPath).row == 2{
            // Get "Conceptos"
            let descripcion = report.descripcion!
            cell.textLabel?.text = "Descripcion:"
           // print("La descripción de la incidencia es: \(descripcion)")
            cell.detailTextLabel?.text = "\(descripcion)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let report = reports[section]
        
        let dateFprmatter = DateFormatter()
        dateFprmatter.dateFormat = "dd MMMM YYYY - hh:mm"
        
        
        //Entidad federativa 
        
        let entidad = report.entidadFederativa!
        
        let carretera = report.carretera!

        
        
       // print("La entidad federativa es: \(entidad.nombre)")
        
      //  print("La carretera  es: \(carretera.nombre)")

        return dateFprmatter.string(from: report.fechaDefinitiva! as Date)+"  "+entidad.nombre+"      "+carretera.nombre
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row == 0{ // Acciones
            performSegue(withIdentifier: "toUpdateAction", sender: indexPath)
        }
        else if (indexPath as NSIndexPath).row == 1{ // Conceptos
            performSegue(withIdentifier: "toUpdateConcept", sender: indexPath)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowFilterPopover"{
            
            HandlerIO.saveFiltersBool(true)
            // Set Popover: iPhone needs this change to show as Popover
            let navController = segue.destination as! UINavigationController
            if let popover = navController.popoverPresentationController {
                popover.delegate = self
            }
        } else if segue.identifier == "toUpdateAction"{
            let actionsTableController = segue.destination as! ActionsTableVC
            
            if let indiceTabla = sender {
                // Se le asigna al ActionsTableVC el valor del reporte seleccionado
                actionsTableController.sectionReport = (indiceTabla as AnyObject).section
                actionsTableController.reporte = reports[((indiceTabla as AnyObject).section)!]
                

            }
            
            
        }
        else if segue.identifier == "toUpdateConcept"{
            let conceptsTableController = segue.destination as! ConceptsTableVC
            if let indiceTabla = sender {
                // Se le asigna al ActionsTableVC el valor del reporte seleccionado
                conceptsTableController.sectionReport = (indiceTabla as AnyObject).section
                conceptsTableController.reporte = reports[((indiceTabla as AnyObject).section)!]
            }
            
            
        }
    }
    
    @IBAction func unwindSelectedFilter(_ segue: UIStoryboardSegue){
        print("unwindSelectedFilter")
        if let catalogController = segue.source as? FilterPopoverController{
            print("datos es\(catalogController.arrayData)")
            filters(catalogController.arrayData)
        }
    }
}


// MARK: - UIPopoverPresentationControllerDelegate

extension UpdateTableVC: UIPopoverPresentationControllerDelegate{
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
