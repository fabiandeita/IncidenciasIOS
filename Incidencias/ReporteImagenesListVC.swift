//
//  ReporteImagenesListVC.swift
//  Incidencias
//
//  Created by Fabián on 26/10/17.
//  Copyright © 2017 PICIE. All rights reserved.
//

import Foundation
import PreviewTransition

public class ReporteImagenesListVC : PTTableViewController {
    //Variables
    
    private let items = [("1", "River cruise"), ("2", "North Island"), ("3", "Mountain trail"), ("4", "Southern Coast"), ("5", "Fishing place")] // image names
    var dataConcepto : NSDictionary!
    var imagenesList : NSArray?
    var accionesrealizadas : String?
    var imagesArray: [UIImage] = []
    
    
    //imagenesList
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        print ("imagenes")
        if(dataConcepto != nil){
            imagenesList = dataConcepto.value(forKey: "imagenesList") as? NSArray
            accionesrealizadas = dataConcepto.value(forKey: "nombre") as? String
        }
        definesPresentationContext = true
        createImagesArray()
    }
    
    private func createImagesArray() {
        
        guard let imagenesList = imagenesList else { return }
        
        for imageStringObject in imagenesList   {
            let imageString = (imageStringObject as AnyObject).value(forKey:"imagenBase64") as! String
            let imageData = NSData(base64Encoded: imageString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            
            if let image = UIImage(data: imageData as Data) {
                imagesArray.append(image)
            }
            else {
                imagesArray.append(UIImage())
            }
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ZoomImageViewController" {
            let indexPath = tableView.indexPathForSelectedRow!
            let image = imagesArray[indexPath.row]
            let zoomImageViewController = segue.destination as! ZoomImageViewController
            zoomImageViewController.image = image
        }
    }
    
}

// MARK: UITableViewDelegate

extension ReporteImagenesListVC {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(imagenesList == nil){
            return 0
        }
        return imagenesList!.count
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let cell = cell as? ParallaxCell else {
            return
        }
        //let index = indexPath.row % it
        var title : String = ""
        
        if (accionesrealizadas != nil) {
            title = accionesrealizadas!.lowercased()
            
        }
        else {
            title = String(indexPath.row)
        }
        
        cell.textLabel?.textColor = UIColor.white
        cell.setImage(imagesArray[indexPath.row], title: title)
    }
    
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ParallaxCell = tableView.dequeueReusableCell(withIdentifier: "ParallaxCell", for: indexPath) as! ParallaxCell
        //let cell: ParallaxCell = tableView.dequeueReusableCell(withIdentifier: "\(indexPath)" ) as! ParallaxCell
         //let cell  = tableView.dequeueReusableCell(withIdentifier: "reportImagenesCell" )
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ZoomImageViewController", sender: self)
    }

}
