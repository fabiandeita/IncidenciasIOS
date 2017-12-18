//
//  ConceptsTableVC.swift
//  Incidencias
//
//  Created by Sebastian on 11/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

class ConceptsTableVC: UITableViewController {
    
    var sectionReport = Int()
    var reporte: Reporte?


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
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("El tamanio de acciones es : \(reporte?.conceptos?.count)")
        
        return (reporte?.conceptos?.count)!
    
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let conceptosAllObjects = reporte?.conceptos?.allObjects
        
        
            //  let accion : AnyObject = accionAllObjects[UInt(indexPath.row)]
            
            if let concepto = conceptosAllObjects?[(indexPath as NSIndexPath).row] as? Concepto {
                print("Site is: \(concepto.descripcion)")
                //cell!.textLabel!.text = action.descripcion
                
                cell.textLabel?.text  = concepto.descripcion!
                
                let conceptoId : String?
                
                conceptoId = String(describing: concepto.id!)
                
                if let conceptoStringId = conceptoId {
                    cell.detailTextLabel?.text = "ID:  "+conceptoStringId
                }
                
                
            } else {
                
                print("Errorr")
                
            }

        return cell
    }
    
    
    // Mark: - IBActions
    
    @IBAction func actionButtonAdd(_ sender: AnyObject) {
    }
    
    
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        
        let navVC = segue.destination as! UINavigationController
        
        
        let newConceptVC = navVC.viewControllers.first as! NewConceptVC
        
        newConceptVC.reporte = reporte
        //newActionVC
        
        newConceptVC.modalPresentationStyle = .popover
        if let popover = newConceptVC.popoverPresentationController {
            popover.barButtonItem = sender as? UIBarButtonItem
        }
        
    }
    

}
