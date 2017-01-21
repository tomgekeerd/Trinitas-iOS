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
    
    var refreshSpinner: UIRefreshControl = UIRefreshControl()
    
    let api = API()
    let dh = DataHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableView setup
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorInset = UIEdgeInsets.zero

        // Refresh control setup
        
        self.refreshSpinner = UIRefreshControl()
        self.refreshSpinner.addTarget(self, action: #selector(persistsRefresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshSpinner)
        
        // Setup dateselector
        
        self.calendarView = CLWeeklyCalendarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 120))
        self.calendarView.delegate = self
        
        self.view.addSubview(self.calendarView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBar show/hide
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Segue handler
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? LessonDetailViewController {
            
            if let cell = sender as? UITableViewCell {
                
                if let indexPath = self.tableView.indexPath(for: cell) {

                    vc.lessonData = self.lessonArray[indexPath.row]
                    
                }
                
            }
            
        }
        
    }

    // MARK: - UIRefreshControl .valueChanged method
    
    func persistsRefresh() {
        
        // User wants a forced refresh from server...
        
        self.setDataInView(date: self.calendarView.selectedDate, forced: true)
        
    }
    
    // MARK: - Receive last update
    
    func setLastUpdateOfCurrentView() {
        
        // Getting last update of the current date displayed, last update is saved within every lesson. Although this is not handy for receiving the last update of a day, the day will always be saved together with all the lessons combined. This method must be called every time the request date changed.
        
        // Calculate last update average lol
        
        var total = 0
        for lesson in self.lessonArray {
            
            total = total + lesson.lastUpdate
            
        }
        
        if total != 0 {
            
            // Calculate average
            
            let average = total / self.lessonArray.count
            let averageDate: Date = Date(timeIntervalSince1970: TimeInterval(average))
            
            // Set title in spinner
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy hh:mm:ss"
            let date = dateFormatter.string(from: averageDate)
            let attributedString = NSAttributedString(string: "Laatste update: \(date)")
            
            // Set title
            
            self.refreshSpinner.attributedTitle = attributedString
            
        }

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
        cell.selectionStyle = .none
        cell.lessonData = currentLesson
        cell.type = currentLesson.type
        
        return cell
        
    }
    
    // MARK: - Data parsing
    
    func setDataInView(date: Date, forced: Bool) {
        
        // Receive schedule of the Date
        
        api.getScheduleOfDay(day: date, forced: forced) { (success, fromDB, result) in
            
            // Got results, reload tableView to display...
            
            self.refreshSpinner.endRefreshing()
            
            // Check if succeeded & got results. Otherwise, do not display any message about results in database
            
            if result.count == 0 {
                
                // No data, display error
                
                self.load(show: false)
                
            } else {
                
                // Data, display in tableview
                
                self.lessonArray = result
                self.resultsFromDB = fromDB
                self.tableView.reloadData()
                
                // Set last update
                
                self.setLastUpdateOfCurrentView()
                
                // Dismiss loading screen
                
                self.load(show: false)
                
            }
            
        }
        
    }
    
    // MARK: - StatusBarStyle
    
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
        
        // Show loading screen & update last update
        
        self.setLastUpdateOfCurrentView()
        self.load(show: true)
        
        // Empty out array, reload tableview for load screen
        
        self.lessonArray = []
        self.resultsFromDB = false
        self.tableView.reloadData()
        
        self.setDataInView(date: date, forced: false)
        
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
