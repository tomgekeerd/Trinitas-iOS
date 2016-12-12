//
//  TableViewCells.swift
//  Trinitas
//
//  Created by Tom de ruiter on 12/12/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import Foundation
import UIKit

class LessonCell: UITableViewCell {
    
    // Lesson outlets
    
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var homeworkIcon: UIImageView!
    
    // Lesson data
    
    var lessonData: Lesson!
    
    // Type of hour
    
    var type: String! {
        
        didSet {
            
            // Set cell type
            
            self.setCellType(type: type)
            
        }
        
    }
    
    // Initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK - Set type functions
    
    func setCellType(type: String) {
        
        if let data = self.lessonData {
            
            // Hide homework
            
            self.homeworkIcon.isHidden = true
            
            // Set hour
            
            if let h = data.hour {
                self.timeLabel.text = "\(h)"
            }
            
            // Grey out cells
            
            self.enable(on: false)

            // Switch through to the options
            
            switch type {
            case "Vrij":
                
                // Set 'Vrij'
                
                self.classLabel.text = "Vrij"
                self.titleLabel.text = "-"
                
                break
                
            case "Eerste uur vrij":
                
                // Set 'eerste uur vrij'
                
                // Should change this for second, third etc hours.
                
                self.classLabel.text = "Eerste uur vrij"
                self.titleLabel.text = "-"
                
                break
                
            case "Tussenuur":
                
                // Set 'tussenuur'
                
                self.classLabel.text = "Tussenuur"
                self.titleLabel.text = "-"
                
                break
                
            case "Les":
                
                // Set 'les' & enable cell
                
                self.enable(on: true)
                
                // Check what kind of lesson this is, a real lesson or subscription
                
                if let lTitle = data.lessonTitle {
                    
                    if lTitle == "Inschrijven" {
                        
                        self.classLabel.text = lTitle
                        self.titleLabel.text = lTitle

                    } else {
                        
                        // Set normal 'les'
                        
                        if let lesson = data.lessonFormat, let homework = data.homework {
                            
                            // Set!
                            
                            self.classLabel.text = lesson
                            self.titleLabel.text = lTitle
                            
                            // Check for homework
                            
                            if homework {
                                
                                self.homeworkIcon.isHidden = false
                                
                            }
                            
                            // Cool for later
                            
//                            if let startInterval = data.start, let endInterval = data.end {
//                                
//                                // Calculate intervals
//                                
//                                let si: Double = Double(startInterval / 1000)
//                                let ei: Double = Double(endInterval / 1000)
//
//                                // Format the intervals
//                                
//                                let dateFormatter = DateFormatter()
//                                dateFormatter.dateFormat = "hh:mm"
//                                
//                                let beginTime = dateFormatter.string(from: Date(timeIntervalSince1970: si))
//                                let endTime = dateFormatter.string(from: Date(timeIntervalSince1970: ei))
//                            
//                                // Set the times in labels
//                                
//                                self.timeLabel.text = "\(beginTime)\n\(endTime)"
//                                
//                            }

                        }
                        
                    }
                    
                }

                break
                
            case "Pauze":
                
                break
            default:
                ()
            }

        }
    
    }
    
}

extension UITableViewCell {
    
    func enable(on: Bool) {
        
        for view in contentView.subviews {
            
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
            
        }
        
    }
    
}
