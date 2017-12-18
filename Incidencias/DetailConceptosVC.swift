//
//  DetailConceptosVC.swift
//  Incidencias
//
//  Created by Fabián on 25/10/17.
//  Copyright © 2017 PICIE. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD



class DetailConceptosVC : UIViewController, UITableViewDataSource, UITableViewDelegate , onResponseApiListener  {
  

    
    
    //https://github.com/nakajijapan/PhotoSlider
    //https://github.com/Ramotion/preview-transition
    
    @IBOutlet weak var tableView: UITableView!
    var totalConceptos : Int?
    var index : Int!
    var conceptosArray : NSArray?
    let items = ["ML", "M2", "M3", "PIEZA", "TONELADA", "KILOGRAMO", "LITROS", "OTRO"]
    
    var sectionReport = Int()
    var emergenciaId = Int()
    var isE7orHistoricReport = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("detail concepto")
        SVProgressHUD.show(withStatus: "Consultando reporte")
        ApiHandler.onResponseApiListenerDelegate = self
        print("is e7 \(isE7orHistoricReport)")
        if(isE7orHistoricReport==0){
            ApiHandler.getReporteHistorico(id: emergenciaId);
            
        }else if(isE7orHistoricReport==1){
            ApiHandler.getReporteE7(id: emergenciaId)
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(totalConceptos)
        if totalConceptos == nil{
            return 0;
        }
        return totalConceptos!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("toGalleryConcepto")
        
        index = indexPath.row
        
        var imagenesList : NSArray?
        
        let data : NSDictionary = conceptosArray!.object(at: index) as! NSDictionary
        
        imagenesList = data.value(forKey: "imagenesList") as? NSArray
        
        if(imagenesList!.count > 0){
            self.performSegue(withIdentifier: "toGalleryConcepto", sender: conceptosArray!.object(at: index) as! NSDictionary)
            
        }else{
            let alert = UIAlertController(title: "Oops!", message:"No hay imagenes para este concepto", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        }
        
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "historicReportCell", for: indexPath) as! HistoricReportCell
        
        // cell.entidad.text = datosReporte.objectAtIndex(indexPath.row).valueForKey("emergencia")?.valueForKey("subtramo")?.valueForKey("entidadfederativa")?.valueForKey("nombre") as! String!
        
        let fechacreacion = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey:"fechacreacion") as! Double
        
        let nombre = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey: "nombre") as! String
        
        let unidad = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey: "unidad") as! Int
        
        let cantidad = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey: "cantidad") as! Double
        
        let fechaactualizacion = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey: "fechacreacion") as! Double
        
        let avances = (conceptosArray?.object(at: indexPath.row) as AnyObject).value(forKey: "avanceS") as! String
        
        print("\nFechacreacion : \(fechacreacion)")
        print("\nNombre : \(nombre)")
        
        
        var unidadSiglas : String = "N/A"
        if unidad <= items.count{
            print("\nUnidad : \(items[unidad])")
            unidadSiglas = items[unidad] as String
        }
        print("\nCantidad : \(cantidad)")
        print("\nAvances : \(avances)")
        
        cell.avance.text = avances
        cell.concepto.text = nombre
        cell.unidad.text = unidadSiglas
        cell.dateHour.text = Utilities.fechaString(timeIs: fechacreacion)
        cell.update.text = Utilities.fechaString(timeIs: fechaactualizacion)
        cell.avance.text = "\(avances) %"
        cell.cantidad.text = String(cantidad)
        
        
        
        return cell
    }
    func onReportFetchFinished(reporte : Reporte) {
        
    }
    
    
    func  onAccionFetchFinished(accion action : Accion) {
        
    }
    
    func onConceptFetchFinished(concepto concept : Concepto) {
        
        
    }
    
    func onImageReportFetchFinished(concepto concept : Concepto){
        
    }
    
    func onReporteE7FetchFinished(responseE7: AnyObject) {
        
    }
    
    func onImageEmergenciasFetchFinished(responseImagenes: AnyObject?) {
        
    }
    
    private func showSimpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    

    func onReporteHistoricoFetchFinished(responseHistorico: AnyObject?) {
        SVProgressHUD.dismiss()
        if let json = responseHistorico{
            if let rootDict = json as? NSDictionary{
                let success = rootDict["success"] as! Int
                var total = rootDict["total"] as! Int
                let dataArray = rootDict["data"] as! NSArray
                print("DetailConceptos Total de reportes \(total) \n")
                
                if total == 0{
                    self.showSimpleAlert(title: "Aviso", message: "No se encontraron reportes\n con esos parametros")
                }else{
                    //self.performSegueWithIdentifier("DetailReport", sender: dataArray)
                    conceptosArray = dataArray
                    totalConceptos = total
                    print("total conceptos \(totalConceptos)")
                    tableView.delegate = self
                    tableView.dataSource = self
                    tableView.reloadData()
                }
                
                if success != 1{
                    self.showSimpleAlert(title: "Aviso", message: "No se encontraron reportes\n con esos parametros")
                }
                
            }
            
            
        }
    }
    
    //Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! ReporteImagenesListVC
        
        
        navController.dataConcepto = sender as? NSDictionary
    }

}
