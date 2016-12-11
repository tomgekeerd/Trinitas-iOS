//
//  RoosterTableViewController.swift
//  Trinitas
//
//  Created by Tom de ruiter on 23/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
import CoreData

class RoosterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScrollableDatepickerDelegate {
    
    @IBOutlet var tableView: UITableView!
    var schedule = [NSManagedObject]()
    var lessonArray = [Lesson]()
    
    let api = API()
    let dh = DataHelper()
    
    @IBOutlet var datepicker: ScrollableDatepicker! {
        didSet {
            let beforeDates = 15
            var dates = [Date]()
            for day in -beforeDates...60 {
                dates.append(Date(timeIntervalSinceNow: Double(day * 86400)))
            }
            
            datepicker.selectedDate = Date()
            datepicker.dates = dates
            datepicker.delegate = self
            datepicker.beforeDates = 15
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableView setup
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "BreakTableViewCell", bundle: nil), forCellReuseIdentifier: "breakCell")
        self.tableView.register(UINib(nibName: "ColouredTableViewCell", bundle: nil), forCellReuseIdentifier: "colouredCell")
        
        let date = Date().addingTimeInterval(3600 * 48)
        api.getScheduleOfDay(day: date) { (success, results) in
            print(results)
            for r in results {
                print(r.hour)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Datepicker delegate methods
    
    func datepicker(_ datepicker: ScrollableDatepicker, didSelectDate date: Date) {
        print(date)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lessonArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentLesson = lessonArray[indexPath.row]
        var cell = UITableViewCell()
        
        switch currentLesson.type {
        case "Vrij":
            
            // Spare time
            
            cell = tableView.dequeueReusableCell(withIdentifier: "spareCell", for: indexPath) as! SpareTableViewCell
            
            break
            
        case "Eerste uur vrij":
            
            // First hour(s) off
            
            cell = tableView.dequeueReusableCell(withIdentifier: "firstOffCell", for: indexPath) as! FirstOffTableViewCell
            
            break
        case "Tussenuur":
            
            // Hour off between lessons
            
            cell = tableView.dequeueReusableCell(withIdentifier: "betweenCell", for: indexPath) as! BetweenTableViewCell

            break
        case "Les":
            
            // Lesson
            
            cell = tableView.dequeueReusableCell(withIdentifier: "colouredCell", for: indexPath) as! ColouredTableViewCell
            cell.selectionStyle = .none
            
            break
        case "Pauze":
            
            // Break
            
            cell = tableView.dequeueReusableCell(withIdentifier: "breakCell", for: indexPath) as! BreakTableViewCell
            
            break
        default:
            ()
        }
        
        // Should prevent this
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
