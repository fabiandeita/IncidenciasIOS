//
//  ActionsTableVC.swift
//  Incidencias
//
//  Created by Sebastian on 11/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

class ActionsTableVC: UITableViewController {
    
    // MARK: Variables
    var reporte: Reporte?
    var acciones = [Accion]()
    var sectionReport = Int()
    
    
    // MARK: Overide Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("El reporte que se paso es\(reporte?.descripcion) " )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let reports = HandlerIO.getReports(){
            self.reporte = reports[sectionReport]
            self.tableView.reloadData()
        }
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func loadActionsData(){
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("El tamanio de acciones es : \(reporte?.acciones?.count)")

        return (reporte?.acciones?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        
        
        let accionAllObjects = reporte?.acciones?.allObjects
        
        
      //  let accion : AnyObject = accionAllObjects[UInt(indexPath.row)]

        if let action = accionAllObjects?[(indexPath as NSIndexPath).row] as? Accion {
            print("Site is: \(action.descripcion)")
            //cell!.textLabel!.text = action.descripcion
            
            cell.textLabel?.text  = action.descripcion

            
            let actionId : String?
            
            actionId = String(describing: action.id!)
            
            
            if let actionStringId = actionId {
                cell.detailTextLabel?.text = "ID:  " + actionStringId
            }

        } else {
            
            print("Errorr")

        }

        
        
        return cell

    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let navVC = segue.destination as! UINavigationController
        
        
        let newActionVC = navVC.viewControllers.first as! NewActionVC
        
        newActionVC.reporte = reporte
            //newActionVC

        newActionVC.modalPresentationStyle = .popover
        if let popover = newActionVC.popoverPresentationController {
            popover.barButtonItem = sender as? UIBarButtonItem
        }
    }
    

    
    
    
}
