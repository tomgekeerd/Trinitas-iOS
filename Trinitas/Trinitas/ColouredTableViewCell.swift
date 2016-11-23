//
//  ColouredTableViewCell.swift
//  Trinitas
//
//  Created by Tom de ruiter on 23/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit

class ColouredTableViewCell: UITableViewCell {

    var color: UIColor! = UIColor.red
    var isGrade: Bool!
    var isBreak: Bool!
    
    @IBOutlet var dataView: UIView!
    @IBOutlet var homeWorkImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var hourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Colors
        
        self.dataView.backgroundColor = color
        self.dataView.layer.cornerRadius = 12
        self.backgroundColor = UIColor.clear
        
        // Homework image
        
//        homeWorkImage.image = homeWorkImage.image?.maskWith(color: UIColor.white)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UIImage {
    
    func maskWith(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }        
}
