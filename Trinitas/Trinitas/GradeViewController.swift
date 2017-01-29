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
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var activityView: UIActivityIndicatorView!
    var refreshSpinner: UIRefreshControl = UIRefreshControl()
    var gradePeriods = [GradePeriod]()
    let api = API()
    
    var period: GradePeriod? {
        if let p = self.gradePeriods.first(where: { $0.period == self.segmentedControl.selectedSegmentIndex }) {
            return p
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        
        self.navigationItem.title = "Periode \(self.segmentedControl.selectedSegmentIndex + 1)"
        self.activityView.startAnimating()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Refresh control setup
        
        self.refreshSpinner = UIRefreshControl()
        self.refreshSpinner.addTarget(self, action: #selector(persistsRefresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshSpinner)

        self.api.getGrades { (success, periods) in
            
            if success {
                if let p = periods {
                    if p.count > 0 {
                        self.gradePeriods = p
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
    
    @IBAction func segmentedIndexChanged() {
        self.navigationItem.title = "Periode \(self.segmentedControl.selectedSegmentIndex + 1)"
        self.tableView.reloadData()
    }
    
    func persistsRefresh() {
        
        self.api.getGrades { (success, periods) in
            
            self.refreshSpinner.endRefreshing()
            
            if success {
                if let p = periods {
                    if p.count > 0 {
                        self.gradePeriods = p
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
    
    // MARK: - Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if segue.identifier == "gradeInfo" {
                if let dest = segue.destination as? GradeDetailsViewController {
                    if let period = self.period {
                        dest.section = period.sections[indexPath.row]
                    }
                }
            }
        }
    }

}

// MARK: UITableViewDelegate & DataSource

extension GradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = gradePeriods.count == 0
        if let period = self.period {
            return period.sections.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SectionCell(style: .value1, reuseIdentifier: "SectionCell")
        cell.selectionStyle = .none
        
        if let period = self.period {
            
            if period.sections[indexPath.row].grades.count == 0 {
                cell.enable(on: false)
            } else {
                cell.accessoryType = .disclosureIndicator
            }
            
            // Set section name & average
            
            cell.textLabel?.text = period.sections[indexPath.row].name
            
            let grade = period.sections[indexPath.row].average
            cell.detailTextLabel?.text = grade
            if grade != "-" {
                cell.detailTextLabel?.setColor(forGrade: Double(grade)!)
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.segmentedControl.selectedSegmentIndex <= 2 {
            return "Cijfers periode \(self.segmentedControl.selectedSegmentIndex + 1)"
        } else {
            return "Examendossier"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let p = self.period {
            if p.sections[indexPath.row].grades.count > 0 {
                self.performSegue(withIdentifier: "gradeInfo", sender: indexPath)
            }
        }
    }
    
}

class SectionCell: UITableViewCell {
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var averageGrade: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

