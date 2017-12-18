//
//  ConfigIPCell.swift
//  Incidencias
//
//  Created by VaD on 29/01/16.
//  Copyright © 2016 PICIE. All rights reserved.
//

import UIKit

class ConfigIPCell: UITableViewCell {

    @IBOutlet var labelText: UILabel!
    @IBOutlet var input: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func saveHostAction(_ sender: UIButton) {
        
        
        
    }
    
}
