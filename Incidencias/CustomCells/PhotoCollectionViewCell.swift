//
//  PhotoCollectionViewCell.swift
//  Incidencias
//
//  Created by Alejandro Tapia on 27/10/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit

protocol DeleteImageDelegate {
    func deleteImageInPosition(_ position:Int)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet weak var deleteCell: UIButton!
    
    
    var position : Int!
    var delegateCell : DeleteImageDelegate!
    
    var shakeEnabled = false
    
    
    func shakeIcons() {
        let shakeAnim = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnim.duration = 0.05
        shakeAnim.repeatCount = 2
        shakeAnim.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/280
        let stopAngle = -startAngle
        shakeAnim.fromValue = NSNumber(value: startAngle as Float)
        shakeAnim.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnim.autoreverses = true
        shakeAnim.duration = 0.2
        shakeAnim.repeatCount = 10000
        shakeAnim.timeOffset = 290 * drand48()
        
        //Create layer, then add animation to the element's layer
        let layer: CALayer = self.photoImageView.layer
        layer.add(shakeAnim, forKey:"shaking")
        self.deleteCell.isHidden = false
        shakeEnabled = true
    }

    func stopShakingIcons() {
        let layer: CALayer = self.photoImageView.layer
        layer.removeAnimation(forKey: "shaking")
        self.deleteCell.isHidden = true
        shakeEnabled = false
    }
    @IBAction func deletaeAction(_ sender: AnyObject) {
        delegateCell.deleteImageInPosition(position)
    }

}
