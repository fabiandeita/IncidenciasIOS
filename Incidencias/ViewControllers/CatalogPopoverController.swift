//
//  CatalogPopoverController.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 20/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData

class CatalogPopoverController: UITableViewController {
    
    // MARK: - Variables
    var catalog = [NSManagedObject]()
    var selectedObject: NSManagedObject!
    var segueType = CatalogSegueType.none
    var isMultiSelect = Bool()
    @IBOutlet var buttonSelecte: UIBarButtonItem!
    var dataEntidades: NSMutableArray = NSMutableArray()
    var objetosEntidades: NSMutableArray = NSMutableArray()
    var objetosEntidadesDB: NSMutableArray = NSMutableArray()
    var selectedEntidad: EntidadFederativa?
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Table View
        if isMultiSelect{
            buttonSelecte.title = "Listo"
        }else{
            buttonSelecte.title = "Cancelar"
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        if segueType == .push{
            // Remove right item button
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalog.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatalogCell")!
        
        // Get Object
        let object = catalog[(indexPath as NSIndexPath).row]
        if let nombre = object.value(forKey: "nombre") as? String {
            // Set Cell
            cell.textLabel?.text = nombre
        }
        if dataEntidades.count != 0{
            var isPendiente = Bool()
            for row in 0 ..< dataEntidades.count {
                if (dataEntidades.object(at: row) as! IndexPath == indexPath)
                {
                    isPendiente = true
                    break
                    
                } else {
                    isPendiente = false
                    
                }
            }
            
            if isPendiente{
                cell.accessoryType = .checkmark;
            }else{
                cell.accessoryType = .none;
            }
            
        }
        else{
            cell.accessoryType = .none;
        }
        
        return cell
    }
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isMultiSelect{
            
            if dataEntidades.count != 0{
                var isPendiente = Bool()
                for row in 0 ..< dataEntidades.count {
                    if (dataEntidades.object(at: row) as! IndexPath == indexPath)
                    {
                        isPendiente = true
                        break
                        
                    } else {
                        isPendiente = false
                        
                    }
                }
                
                if isPendiente{
                    dataEntidades.remove(indexPath)
                    addObjectDB(catalog[(indexPath as NSIndexPath).row], isremove: true, indexIs: (indexPath as NSIndexPath).row)
                    objetosEntidadesDB.remove(catalog[(indexPath as NSIndexPath).row])
                }else{
                    dataEntidades.add(indexPath)
                    addObjectDB(catalog[(indexPath as NSIndexPath).row], isremove: false, indexIs: (indexPath as NSIndexPath).row)
                    objetosEntidadesDB.add(catalog[(indexPath as NSIndexPath).row])
                    
                }
                
            }else{
                
                dataEntidades.add(indexPath)
                addObjectDB(catalog[(indexPath as NSIndexPath).row], isremove: false, indexIs: (indexPath as NSIndexPath).row)
                objetosEntidadesDB.add(catalog[(indexPath as NSIndexPath).row])
                
            }
            
            tableView.reloadData()
            
        }else{
            switch segueType{
            case .popover:
                self.performSegue(withIdentifier: "SegueUnwinPopover", sender: tableView.cellForRow(at: indexPath))
            case .popoverReport:
                self.performSegue(withIdentifier: "SegueUnwinReport", sender: tableView.cellForRow(at: indexPath))
            case .push:
                self.performSegue(withIdentifier: "SegueUnwinShow", sender: tableView.cellForRow(at: indexPath))
            case .popoverSign:
                self.performSegue(withIdentifier: "SegueUnwinSignNew", sender: tableView.cellForRow(at: indexPath))
            default:
                print("None segueType")
            }
        }
    }
    
    func addObjectDB(_ sender: AnyObject?, isremove:Bool, indexIs:Int){
        if isremove {
            
            if let object = sender as? EntidadFederativa {
                
                if object != selectedEntidad {
                    selectedEntidad = object
                    objetosEntidades.remove(selectedEntidad?.value(forKey: "id") as! Int)
                }
            }
        }else{
            if let object = sender as? EntidadFederativa {
                
                if object != selectedEntidad {
                    selectedEntidad = object
                    objetosEntidades.add(selectedEntidad?.value(forKey: "id") as! Int)
                }
            }
            
        }
    }
    // MARK: IBAction Methods
    
    @IBAction func actionButtonCancel(_ sender: AnyObject) {
        if isMultiSelect{
            self.performSegue(withIdentifier: "SegueUnwinReport", sender: self)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isMultiSelect{
            if let object = objetosEntidadesDB.firstObject as? NSManagedObject {
                selectedObject = object
            }
            
        }else{
            
            if let cell = sender as? UITableViewCell{
                let indexPath = tableView.indexPath(for: cell)
                selectedObject = catalog[((indexPath as NSIndexPath?)?.row)!]
            }
        }
        
    }
    
}
