//
//  ReportViewCell.swift
//  Incidencias
//
//  Created by MobileStudio04 on 22/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

class ReportViewCell: UITableViewCell {

    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet var fechaEmergencia: UILabel!
    @IBOutlet var entidad: UILabel!
    @IBOutlet var carretera: UILabel!
    @IBOutlet weak var descripcion: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
