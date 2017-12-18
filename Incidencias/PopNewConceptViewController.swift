//
//  PopNewConceptViewController.swift
//  Incidencias
//
//  Created by Hugo Mauricio Jimenez on 20/05/16.
//  Copyright © 2016 PICIE. All rights reserved.
//

import UIKit

protocol SelectItem {
    func itemSelected(_ texto:String, indice: Int)
}

class PopNewConceptViewController: UITableViewController {
    
    var itemSelectNewConceptDelegate : SelectItem!
    var items: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("El titulo es el siguiente \(self.title)")
        
        items.removeAll()
        if self.title == "Unidad"{
            
          /*  Estos son los valores
            
            1 = ML
            2 = M2
            3 = M3
            4 = Pieza
            5 = Tonelada
            6 = Kilogramos
            7 = Litros
            8 = Otros*/
            
            items = ["ML", "M2", "M3", "PZA", "TON", "KG", "LTS", "OTRO"]

            
        }else if self.title == "Avance"{
            
            for index in 0...100 {
                items.append(String(index)+"%")
            }
        }else if self.title == "Dependencia"{
            
            items = ["SUBSECRETARÍA DE INFRAESTRUCTURA",
                "COORDINACIÓN GENERAL DE CENTROS SCT",
                "DGCC",
                "CENTRO SCT AGS",
                "CENTRO SCT BC",
                "CENTRO SCT BCS",
                "CENTRO SCT CAMP",
                "CENTRO SCT COAH",
                "CENTRO SCT COL",
                "CENTRO SCT CHIS",
                "CENTRO SCT CHIH",
                "CENTRO SCT DGO",
                "CENTRO SCT GTO",
                "CENTRO SCT GRO",
                "CENTRO SCT HGO",
                "CENTRO SCT JAL",
                "CENTRO SCT MEX",
                "CENTRO SCT MICH",
                "CENTRO SCT MOR",
                "CENTRO SCT NAY",
                "CENTRO SCT NL",
                "CENTRO SCT OAX",
                "CENTRO SCT PUE",
                "CENTRO SCT QRO",
                "CENTRO SCT QROO",
                "CENTRO SCT SLP",
                "CENTRO SCT SIN",
                "CENTRO SCT SON",
                "CENTRO SCT TAB",
                "CENTRO SCT TAMS",
                "CENTRO SCT TLAX",
                "CENTRO SCT VER",
                "CENTRO SCT YUC",
                "CENTRO SCT ZAC"]

        }else if self.title == "Cargo"{
            
            items = ["MANDO SUPERIOR",
                    "DIRECTOR GENERAL ADJUNTO",
                    "DIRECTOR DE ÁREA",
                    "SUBDIRECTOR DE ÁREA",
                    "JEFE DE DPTO.",
                    "SUPERVISOR DE OBRA",
                    "RESIDENTE GENERAL DE CONSERVACIÓN DE CARRETERAS",
                    "RESIDENTE DE OBRA",
                     "OTRO"]

        }
        self.tableView.reloadData()


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
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let index = (indexPath as NSIndexPath).row
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL") as UITableViewCell!
        cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL")
        /*if cell == nil {
        cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        /*cell.textLabel?.text = sectionsForLevel[indexPath.row]*/
        }*/
        cell?.textLabel?.text = items[index]
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath){
        itemSelectNewConceptDelegate.itemSelected(items[(indexPath as NSIndexPath).row],indice: (indexPath as NSIndexPath).row)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
    // Configure the cell...
    return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
