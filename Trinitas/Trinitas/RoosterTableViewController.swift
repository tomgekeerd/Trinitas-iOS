//
//  RoosterTableViewController.swift
//  Trinitas
//
//  Created by Tom de ruiter on 23/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class RoosterTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var calendarView: CLWeeklyCalendarView!

    var schedule = [NSManagedObject]()
    var lessonArray = [Lesson]()
    var resultsFromDB: Bool = false
    
    let api = API()
    let dh = DataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar setup
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // UITableView setup
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // Setup dateselector
        
        self.calendarView = CLWeeklyCalendarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120))
        self.calendarView.delegate = self
        
        self.view.addSubview(self.calendarView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lessonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentLesson = self.lessonArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath) as! LessonCell
        cell.lessonData = currentLesson
        cell.type = currentLesson.type
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension RoosterTableViewController: CLWeeklyCalendarViewDelegate {
    
    // MARK: - Datepicker delegate method(s)
    
    public func clCalendarBehaviorAttributes() -> [AnyHashable : Any]! {

        return [
            CLCalendarWeekStartDay: 1,
            CLCalendarBackgroundImageColor: UIColor(red: 224/255, green: 54/255, blue: 56/255, alpha: 1.0),
        ]
        
    }
    
    func dailyCalendarViewDidSelect(_ date: Date!) {
        
        // Show loading screen
        
        self.load(show: true)
        
        // Empty out array, reload tableview for load screen
        
        self.lessonArray = []
        self.resultsFromDB = false
        self.tableView.reloadData()
        
        // Receive schedule of the Date
        
        api.getScheduleOfDay(day: date) { (success, fromDB, result) in
            
            // Got results, reload tableView to display...
            
            // Check if succeeded & got results. Otherwise, do not display any message about results in database
            
            if result.count == 0 {
                
                // No data, display error
                
                
            } else {
                
                // Data, display in tableview
                
                self.lessonArray = result
                self.resultsFromDB = fromDB
                self.tableView.reloadData()
                
                // Dismiss loading screen
                
                self.load(show: false)
 
            }
            
        }

    }
    
}

extension RoosterTableViewController {
    
    func load(show: Bool) {
        
        if show {
            
            self.view.isUserInteractionEnabled = false
            SVProgressHUD.show()
            
        } else {
            
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
            
        }
        
    }
    
}
