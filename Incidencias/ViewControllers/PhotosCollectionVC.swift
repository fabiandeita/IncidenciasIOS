//
//  PhotosCollectionVC.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 27/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
// New Framework to iOS 9
// Photos remplace AssetsLibrary to Camera and Gallery Resources
import Photos

protocol PhotosCollectionVCDelegate {
    func photosCollectionVCChange(_ photos: [Photo], type: PhotoType)
}

enum PhotoType{
    case noValue
    case reporte
    case croquis
    case accion
    case concepto
}


class PhotosCollectionVC: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DeleteImageDelegate {
    
    // MARK: - Variables
    var photos = [Photo]()
    var delegate: PhotosCollectionVCDelegate?
    var photoType = PhotoType.noValue
    
    var animatedCell : Bool = true
    
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide Tab Bar
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func setAndPresentPickerControllerWithSourceType(_ sourceType: UIImagePickerControllerSourceType, buttonItem: UIBarButtonItem) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        
        // Only to Source Type Camera
        if sourceType == .camera{
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
        }
        
        // Settings for iPad (Show has Popover)
        pickerController.modalPresentationStyle = .popover
        if let popover = pickerController.popoverPresentationController {
            popover.barButtonItem = buttonItem
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    fileprivate func showRequestOpenSettingsWithSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        
        var message: String!
        switch sourceType {
        case .camera:
            message = "Para habilitar el permiso de la Camara vaya a Configuraciones > Privacidad > Camara. Y autorice para esta app."
        case .photoLibrary:
            message = "Para habilitar el permiso de la Fotos vaya a Configuraciones > Privacidad > Fotos. Y autorice para esta app."
        default:
            print("Source Type is not CAMERA noder PHOTO LIBRARY")
        }
        
        // Alert Controller
        let alertController = UIAlertController(title: "Permiso denegado", message: message, preferredStyle: .alert)
        
        // Actions
        let actionCancel = UIAlertAction(title: "Cerrar", style: .default, handler: nil)
        let actionSettings = UIAlertAction(title: "Config", style: .default) { (action) -> Void in
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionSettings)
        
        // Show
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        // Set Cell
        let photo = photos[(indexPath as NSIndexPath).row]
        cell.photoImageView.image = UIImage(data: photo.data as Data)
        
        cell.deleteCell.layer.cornerRadius = cell.deleteCell.frame.size.width/2
        cell.deleteCell.clipsToBounds = true
        
        cell.position = (indexPath as NSIndexPath).row
        cell.delegateCell = self
        
        //self.loginButton.buscarDepartamentoBoton.addTarget(self, action: #selector(HomeViewC_layout.goDepartament), forControlEvents: .TouchUpInside)
        
        //add gesture for delete cell
        //let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(PhotosCollectionVC.reset(_:)))
       let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(PhotosCollectionVC.reset(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
       // lpgr.delegate = self
       
        cell.addGestureRecognizer(lpgr)
    
        return cell
    }
    
    func deleteImageInPosition(_ position: Int) {
        print("borrar \(position)")
        photos.remove(at: position)
        delegate?.photosCollectionVCChange(photos, type: photoType)
        self.collectionView?.reloadData()
        
    }
    
    func reset(_ sender: UISwipeGestureRecognizer) {
        
        if sender.state == .ended{
            print("Eliminar celda")
            if animatedCell{
               AnimatedCell(true)
                animatedCell = false
            }else{
                AnimatedCell(false)
                animatedCell = true
            }
        }
    }
    
    func AnimatedCell(_ isAnimated:Bool) {
        if isAnimated{
            for item in self.collectionView!.visibleCells as! [PhotoCollectionViewCell] {
                let indexPath: IndexPath = self.collectionView!.indexPath(for: item as PhotoCollectionViewCell)!
                let cell: PhotoCollectionViewCell = self.collectionView!.cellForItem(at: indexPath) as! PhotoCollectionViewCell!
                cell.deleteCell.isHidden = false // show all of the delete buttons
                cell.shakeIcons()
            }
        }else{
            for item in self.collectionView!.visibleCells as! [PhotoCollectionViewCell] {
                let indexPath: IndexPath = self.collectionView!.indexPath(for: item as PhotoCollectionViewCell)!
                let cell: PhotoCollectionViewCell = self.collectionView!.cellForItem(at: indexPath) as! PhotoCollectionViewCell!
                cell.deleteCell.isHidden = true // show all of the delete buttons
                cell.stopShakingIcons()
            }
        }
        
    }
    
    
    // MARK: IBActions
    
    @IBAction func ActionButtonAdd(_ sender: AnyObject) {
        
        // Set Alert Controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Actions
        let actionCamera = UIAlertAction(title: "Camara", style: .default) { (action) -> Void in
            
            // Check if device has a Camera
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                
                let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                if status == AVAuthorizationStatus.authorized {
                    print("Camera is AUTHORIZED")
                    
                    // Set and Preset Camera Picker Controller
                    self.setAndPresentPickerControllerWithSourceType(.camera, buttonItem: sender as! UIBarButtonItem)
                }
                else if status == AVAuthorizationStatus.notDetermined {
                    print("Camera is NOT DETERMINED")
                    
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (bool) -> Void in
                        
                        if bool {
                            self.setAndPresentPickerControllerWithSourceType(.camera, buttonItem: sender as! UIBarButtonItem)
                        }
                        else{
                            self.showRequestOpenSettingsWithSourceType(.camera)
                        }
                    })
                }
                else{
                    print("Camera is DENIED")
                    self.showRequestOpenSettingsWithSourceType(.camera)
                }
            }
            else{
                // Show Alert View
                let alertController = UIAlertController(title: "Sin Camara", message: "Lo sentimos, este dispositivo no tiene camara.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        let actionGallery = UIAlertAction(title: "Galería", style: .default) { (action) -> Void in
            
            let status = PHPhotoLibrary.authorizationStatus()
            if status == PHAuthorizationStatus.authorized {
                print("Gallery id AUTHORIZED")
                
                // Set and Present Photo Library Picker Controller
                self.setAndPresentPickerControllerWithSourceType(.photoLibrary, buttonItem: sender as! UIBarButtonItem)
            }
            else if status == PHAuthorizationStatus.notDetermined {
                print("Gallery is NOT DETERMINED")
                
                // Request Authorization
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    
                    if status == PHAuthorizationStatus.authorized {
                        self.setAndPresentPickerControllerWithSourceType(.photoLibrary, buttonItem: sender as! UIBarButtonItem)
                    }
                    else{
                        self.showRequestOpenSettingsWithSourceType(.photoLibrary)
                    }
                })
            }
            else{
                print("Gallery is DENIED")
                self.showRequestOpenSettingsWithSourceType(.photoLibrary)
            }
        }
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        // Add Actions
        alertController.addAction(actionCamera)
        alertController.addAction(actionGallery)
        alertController.addAction(actionCancel)
        
        // Set Alert Controller in iPad
        if let popover = alertController.popoverPresentationController {
            if let buttonItem = sender as? UIBarButtonItem {
                popover.barButtonItem = buttonItem
            }
        }

        // Show
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("imagePickerController - didFinishPickingImage")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Create Photo object with Image Data and current Date Name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyyyyHHmmssSS"
            
            let id: Int64 = Int64(dateFormatter.string(from: Date()))!
            var name: String!
            switch photoType{
            case .reporte:
                name = "reporte\(id)"
            case .accion:
                name = "accion\(id)"
            case .concepto:
                name = "concepto\(id)"
            case .croquis:
                name = "croquis\(id)"
            default:
                name = "\(id)"
            }
            
            photos.append(Photo(name: name, data: UIImageJPEGRepresentation(image, 0.25)!))
            AnimatedCell(false)
            animatedCell = true
            delegate?.photosCollectionVCChange(photos, type: photoType)
        }
        
        picker.dismiss(animated: true) { () -> Void in
            self.collectionView?.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Prepare For Segue")
        
        if let cell = sender as? UICollectionViewCell {
            AnimatedCell(false)
            animatedCell = true
            let indexPath = self.collectionView!.indexPath(for: cell)!
            let controller = segue.destination as! DetailPhotosVC
            controller.image = UIImage(data: photos[(indexPath as NSIndexPath).row].data as Data)
        }
    }
}
