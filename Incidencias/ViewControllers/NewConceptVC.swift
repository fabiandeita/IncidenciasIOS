//
//  PopUpConceptsVC.swift
//  Incidencias
//
//  Created by Sebastian on 11/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD


class NewConceptVC: UIViewController,SelectItem  {
    
    
    // MARK: - Variables
    var conceptoPhotos = [Photo]()
    var managedObjectContext: NSManagedObjectContext!
    var reporte: Reporte?
    
    var selectedAvance : Int?
    
    var selectedUnidad : Int?

    
    // MARK: - Override Methods
    
    @IBOutlet weak var nombreConcepto: UITextField!
    @IBOutlet weak var cantidadConcepto: UITextField!
    @IBOutlet weak var unidadButton: UIButton!
    @IBOutlet weak var AvanceButton: UIButton!
    //buttons of constrains
    @IBOutlet weak var hideButton: NSLayoutConstraint!

    
    var currentButton: UIButton!
    let newVC  = PopNewConceptViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unidadButton.titleLabel?.textAlignment = NSTextAlignment.center
        AvanceButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        
        // Get Core Data Manager Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        cantidadConcepto.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    //Calls this function when the tap is recognized.
    override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(NewConceptVC.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewConceptVC.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWasShown(_ notification: Notification)
    {
        print("el teclado se va a mostrar")
        
        let info = (notification as NSNotification).userInfo!
        
        let keyboardSize = info [UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        let keyboardRect = keyboardSize.cgRectValue
        
        //photosButton.constant = keyboardRect.height
        hideButton.constant = keyboardRect.height
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 

    }
    
    func keyboardWillBeHidden(_ aNotification: Notification) {
        print("el teclado se va a ocultar")
        
        //photosButton.constant = 0
        hideButton.constant = 0
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
        

    }

    
    // MARK: - IBActions
    @IBAction func hideKeyboard(_ sender: AnyObject) {
        nombreConcepto.resignFirstResponder()
        cantidadConcepto.resignFirstResponder()
        unidadButton.resignFirstResponder()
        AvanceButton.resignFirstResponder()
    }
    
    @IBAction func actionbuttons(_ sender: UIButton) {
        
        currentButton = sender
        
        if sender == unidadButton{
            newVC.title = "Unidad"
        }else{
            newVC.title = "Avance"
        }
        newVC.itemSelectNewConceptDelegate = self
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    
    @IBAction func actionButtonCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func itemSelected(_ texto: String, indice : Int) {
        self.navigationController?.popViewController(animated: true)
        print("Este es el Texto \(texto)")
        if currentButton == unidadButton{
            
            unidadButton.setTitle(texto, for: UIControlState())
        
            selectedUnidad  = Int(indice + 1)
            
            print("Este es el simobolo de la unidad \(texto) y este es el valor \(selectedUnidad!)")

            
        }else{
            
            AvanceButton.setTitle(texto, for: UIControlState())

            selectedAvance  = Int(indice )
            
            print("Este es el simobolo de la unidad \(texto) y este es el valor \(selectedAvance!)")


        }
    }
    
    // MARK: - Navigation Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowPhotosCollectionVC"{
            let photosCollectionVC = segue.destination as! PhotosCollectionVC
            photosCollectionVC.delegate = self
            photosCollectionVC.photos = self.conceptoPhotos
            photosCollectionVC.photoType = .concepto
            
            // Set Photos Collection VC from Image Croquis
        }
    }
    
    @IBAction func saveConceptAction(_ sender: AnyObject) {
        
        // Validate all Values, recopilate all values faild and show in AlertView
        var message = ""
        
        // 1. "Datos de Ubicación"
        if nombreConcepto.text!.isEmpty{
            message += "Concepto \n"
        }
        if cantidadConcepto.text!.isEmpty{
            message += "Cantidad \n"
        }
        if selectedAvance == nil {
            message += "Avance \n"

        }
        if selectedUnidad == nil {
            message += "Unidad \n"
            
        }
        
        
        // Save or show alert to validate
        if message.isEmpty{
            
            // Create New Alert
            let description = NSEntityDescription.entity(forEntityName: "Concepto", in: self.managedObjectContext)!
            let concepto = Concepto(entity: description, insertInto: self.managedObjectContext)
            
            
           /* @NSManaged var cantidad: NSNumber?
            @NSManaged var ccve: String?
            @NSManaged var ccveEmergencia: String?
            @NSManaged var descripcion: String?
            @NSManaged var fechaCreacion: NSDate?
            @NSManaged var icve: NSNumber?
            @NSManaged var icveEmergencia: NSNumber?
            @NSManaged var icveUnidad: NSNumber?
            @NSManaged var id: NSNumber?
            @NSManaged var iporAvance: NSNumber?
            @NSManaged var imagenes: NSSet?
            @NSManaged var reporte: Reporte? */

            // Set Attributes
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyyHHmmssSS"
            
            let dateCreaton = dateFormatter.string(from: Date())
            
            let id: Int64 = Int64(dateCreaton)!
            concepto.id = NSNumber(value: id as Int64)
            
            concepto.descripcion = nombreConcepto.text!
            concepto.icveUnidad = selectedUnidad! as NSNumber?
            concepto.reporte = reporte
            concepto.iporAvance = selectedAvance! as NSNumber?
            concepto.fechaCreacion = Date()
            concepto.cantidad = Double(cantidadConcepto.text!) as NSNumber!
            
            // Save "Photos"
            for photo in conceptoPhotos{
                
                // Create New Model Object "Imagen"
                let description = NSEntityDescription.entity(forEntityName: "Imagen", in: self.managedObjectContext)!
                let imagen = Imagen(entity: description, insertInto: self.managedObjectContext)
                
                // Set Attributes
                imagen.id = NSNumber(value: id as Int64)
                imagen.name = photo.name
                imagen.file = photo.data
                
                // Add "Imagen" al Concepto
                concepto.addImagenToConcepto(imagen)
            }
            reporte?.hasBeedModified = true

            // Save
            do {
                try self.managedObjectContext.save()
                
                // Show Progress Success
                SVProgressHUD.showSuccess(withStatus: "Alerta guardada!")
                
                // Clear or Reset all Values
               // self.clearAndResetAllValues()
                
            } catch {
                fatalError("Failure to save context in Entidades Federativas, with error: \(error)")
            }
            
            
            do{
                //Guardamos el reporte hasBeedModified = true
                try reporte!.managedObjectContext?.save()
                
            }catch let error as NSError {
                print("Could not save \(error), \(error.userInfo))")
                
            }
            
        }
        else{
            // Alert Controller
            let alert = UIAlertController(title: "Datos faltantes", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension NewConceptVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nombreConcepto{
            cantidadConcepto.becomeFirstResponder()
        }
        else if textField == cantidadConcepto {
            unidadButton.becomeFirstResponder()
            AvanceButton.becomeFirstResponder()
        }
        else {
            //llamar la funcion para mostrar la alerta
        }
        return true
    }
    
    //TODO implementar esta funcion
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        let aSet = CharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - PhotoCollectionVC Delegate

extension NewConceptVC: PhotosCollectionVCDelegate {
    
    func photosCollectionVCChange(_ photos: [Photo], type: PhotoType) {
        
        switch type{
        case .concepto:
            self.conceptoPhotos = photos

        default:
            print("Return Photos without PhotoType")
        }
    }
}
