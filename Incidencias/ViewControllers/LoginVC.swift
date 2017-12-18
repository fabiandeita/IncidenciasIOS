//
//  LoginVC.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 16/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

//http://10.0.0.6:7001/EmergenciasWS/auth/admsegloginmovil.action?data=GONZRJ89

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set HUD
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        
        print( HandlerIO.getHostServices())
        // Make Test Login Request
        // User: GONZRJ89
        // Password: GONZRJ89
        /*
        Alamofire.request(.GET, "http://10.0.0.6:7001/EmergenciasWS/auth/admsegloginmovil.action", parameters: ["data": "GONZRJ89"])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                //print(response.data)     // server data
                print(response.result)   // result of response serialization
                                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {  
        self.view.endEditing(true)
    }
    
    
    // MARK: Private Methods
    
    fileprivate func showSimpleAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: IBAction Methods
    
    @IBAction func actionButtonLogin(_ sender: AnyObject) {
        
        if userTextField.text!.isEmpty || passwordTextField.text!.isEmpty{
            showSimpleAlert("Datos Incompletos", message: "Favor de escribir usuario y contraseña")
        }
        else if !HandlerIO.isUserDataCorrect(userTextField.text!, password: passwordTextField.text!){
            // Make Request to validate User and Password
            SVProgressHUD.show()
            
            print("LA URL ES: http://\(HandlerIO.getHostServices())/EmergenciasWS/auth/admsegloginmovil.action")
            
            Alamofire.request( "http://\(HandlerIO.getHostServices())/EmergenciasWS/auth/admsegloginmovil.action", method: .get,parameters: ["data": userTextField.text!])
                .responseJSON { response in
                    // Stop HUD
                    SVProgressHUD.dismiss()
                    
                    if let json = response.result.value{
                        if let rootDict = json as? NSDictionary{
                            let success = rootDict["success"] as! Int
                            let total = rootDict["total"] as! Int
                            
                            // Validate User Exist
                            if success == 1 && total == 1{
                                
                                let dataArray = rootDict["data"] as! NSArray
                                let data = dataArray.firstObject as! NSDictionary
                                //print("Data: \(data)")
                                
                                // Get Password and Validate
                                let password = data["cpassword"] as! String
                                if password == self.passwordTextField.text!{
                                    
                                    // Save User and Password
                                    HandlerIO.saveUser(self.userTextField.text!, password: self.passwordTextField.text!)
                                    
                                    // GO TO MAIN!!
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.showMainViewController()
                                }
                                else{
                                    self.showSimpleAlert("Password Incorrecto", message: "El password que ingresaste no corresponde al usuario \(self.userTextField.text!)")
                                }
                            }
                            else{
                                self.showSimpleAlert("Usuario Invalido", message: "El usuario \(self.userTextField.text!) no existe")
                            }
                        }
                    }
                    else{
                        print("Request Login Error: \(response.result.error)")
                    }
            }
        }
        else{
            // Save User and Password
            HandlerIO.saveUser(self.userTextField.text!, password: self.passwordTextField.text!)
            
            // GO TO MAIN!!
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showMainViewController()
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
            self.actionButtonLogin(self)
        }
        
        return true
    }
    
    
}
