//
//  GradeViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/28/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit

class GradeViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var gradePeriods = [GradePeriod]()
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.api.getGrades { (success, periods) in
            
            if success {
                if let p = periods {
                    if p.count > 0 {
                        self.gradePeriods = p
                        print(self.gradePeriods)
                        self.tableView.reloadData()
                    } else {
                        self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later nog eens")
                    }
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later nog eens")
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UITableViewDelegate & DataSource

extension GradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = gradePeriods.count == 0
        if let period = self.gradePeriods.first(where: { $0.period == section }) {
            return period.sections.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradeCell", for: indexPath) as! GradeCell

        if let period = self.gradePeriods.first(where: { $0.period == indexPath.section }) {
            
            // Set section name & average
            
            cell.textLabel?.text = period.sections[indexPath.row].name
            cell.detailTextLabel?.text = period.sections[indexPath.row].average
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Periode 1"
        case 1:
            return "Periode 2"
        case 2:
            return "Periode 3"
        default:
            ()
        }
        return ""
    }
    
    
}

class GradeCell: UITableViewCell {
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var averageGrade: UILabel!
}

