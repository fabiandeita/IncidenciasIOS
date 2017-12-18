//
//  reportUpdateCell.swift
//  Incidencias
//
//  Created by Mobile on 5/23/16.
//  Copyright © 2016 PICIE. All rights reserved.
//


import UIKit

class reportUpdateCell: UITableViewCell {
    
    @IBOutlet weak var descripcionCell: UILabel!
    @IBOutlet weak var idCell: UILabel!
    @IBOutlet weak var statusImage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
