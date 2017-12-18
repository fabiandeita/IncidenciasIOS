//
//  DatePickerPopoverController.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 18/11/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

class DatePickerPopoverController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: Variables
    var selectedDate: Date?
    var segueType :Int!
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\nValor\(segueType)\n")
        if let date = selectedDate{
            datePicker.date = date
        }
        else{
            selectedDate = datePicker.date
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - IBActions
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueType{
        case 0:
            selectedDate = datePicker.date
        case 1:
            selectedDate = datePicker.date
            
        default:
            print("None segueType")
        }
    }
    
    @IBAction func dateBack(_ sender: UIBarButtonItem) {
        switch segueType{
        case 0:
            selectedDate = datePicker.date
            self.performSegue(withIdentifier: "SegueUnwinDate", sender: self)
        case 1:
            selectedDate = datePicker.date
            self.performSegue(withIdentifier: "SegueUnwinReportDate", sender: self)
            
        default:
            print("None segueType")
        }
        
    }
    @IBAction func actionChangeDate(_ sender: AnyObject) {
        selectedDate = datePicker.date
    }
    
    @IBAction func actionButtonCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
