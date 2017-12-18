//
//  ReportsTableVC.swift
//  Incidencias
//
//  Created by MobileStudio04 on 22/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

class ReportsTableVC: UITableViewController {
    let array = ["item1","item2","item3","item4","item5","item6"]
    var datosReporte : NSArray!
    var index : Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //print(datosReporte)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show Tab Bar
        self.tabBarController?.tabBar.isHidden = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datosReporte.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! ReportDetailTableVC
        navController.dataEmergencia = sender as? NSDictionary
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportViewCell
        
        let folio : Int = ((datosReporte.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "emergencia") as AnyObject).value(forKey: "emergenciaid") as! Int
        cell.folioLabel.text = "\(folio)"
        
        //TODO (validar si es null)
        //let dateIs : Int = //datosReporte.objectAtIndex(indexPath.row).valueForKey("emergencia")?.valueForKey("fechacreacionDate") as! Int
        
        let emergencia  = (datosReporte.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "emergencia")
        
        var dateIs : AnyObject?
        
        var dateCreation : Int = 0

        
        if let emergencianotnull = emergencia{
            dateIs  = (emergencianotnull as! AnyObject).value(forKey: "fechacreacionDate") as AnyObject
            
        //let dateIs : Int = datosReporte.objectAtIndex(indexPath.row).valueForKey("emergencia")?.valueForKey("fechacreacionDate")as! Int
            
            
            if let dateValidate = dateIs{
            
                print("DateValidate \(dateValidate)")
                do {
                    
                    if dateValidate is NSNull {
                        print("dateValidate is NSNull")

                    }else{
                        try dateCreation = dateValidate as! Int
                        print("DateCreation \(dateCreation)")
                        
                        if let theDate = Date(jsonDate: "/Date(\(dateCreation))/") {
                            let dateFormatterService = DateFormatter()
                            dateFormatterService.dateFormat = "yyyy-MM-dd"//"M/d/yyyy h:mm:ss a"
                            cell.fechaEmergencia.text = dateFormatterService.string(from: theDate)
                        } else {
                            print("wrong format")
                        }

                    }
                    

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }

            
        }
        
        

        
        
        

        cell.fechaEmergencia.adjustsFontSizeToFitWidth = true
        
        cell.entidad.text = ((((datosReporte.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "entidadfederativa") as AnyObject).value(forKey: "nombre") as! String!
        
        cell.carretera.text = ((((datosReporte.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "emergencia") as AnyObject).value(forKey: "subtramo") as AnyObject).value(forKey: "tramo") as AnyObject).value(forKey: "origen") as! String!
        
        cell.descripcion.text = ((datosReporte.object(at: (indexPath as NSIndexPath).row) as AnyObject).value(forKey: "emergencia") as AnyObject).value(forKey: "descripcion") as! String!
        
        if (indexPath as NSIndexPath).row%2 == 0{
            cell.backgroundColor = UIColor(red: 224.0/255, green: 224.0/255, blue: 224.0/255, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor.white
        }
        

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Acciones")
        
        index = (indexPath as NSIndexPath).row
        
        self.performSegue(withIdentifier: "toDetailReport", sender: datosReporte.object(at: index) as! NSDictionary)
        
        
    }

    
    }
