//
//  MainTabBarController.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 16/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import SVProgressHUD

class MainTabBarController: UITabBarController {

    // MARK: Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set HUD
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: IBActions
    
    @IBAction func actionClickedLogout(_ sender: AnyObject){
        
        // Alert Controller
        let alert = UIAlertController(title: "Cerrar Sesión", message: "De verdad quieres cerrar la sesión?", preferredStyle: .actionSheet)
        
        // Actions
        let acceptAction = UIAlertAction(title: "Si, salir", style: .destructive) { (action) -> Void in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showLoginViewController()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(acceptAction)
        alert.addAction(cancelAction)
        
        // Set Alert Controller in iPad
        if let popover = alert.popoverPresentationController {
            if let buttonItem = sender as? UIBarButtonItem {
                popover.barButtonItem = buttonItem
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            alert.addAction(cancelAction)
        }
        
        // Show
        self.present(alert, animated: true, completion: nil)
        
    }
}
