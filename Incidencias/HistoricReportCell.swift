//
//  HistoricReportCell.swift
//  Incidencias
//
//  Created by Fabián on 26/10/17.
//  Copyright © 2017 PICIE. All rights reserved.
//

import UIKit

class HistoricReportCell: UITableViewCell {

    
    @IBOutlet weak var dateHour: UILabel!
    @IBOutlet weak var concepto: UILabel!
    @IBOutlet weak var unidad: UILabel!
    @IBOutlet weak var cantidad: UILabel!
    @IBOutlet weak var update: UILabel!
    @IBOutlet weak var avance: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
