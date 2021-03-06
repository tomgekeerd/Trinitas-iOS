//
//  GradeDetailsViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/28/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit

class GradeDetailsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var section: Section!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = section.name
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension GradeDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.section.grades.filter({ $0.type == 0 }).count
        default:
            ()
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GradeInfoCell", for: indexPath) as! GradeInfoCell
            cell.selectionStyle = .none
            
            if let averageGrade = self.section.grades.first(where: { $0.type == 1 }) {
                cell.averageGrade.text = averageGrade.mark
                cell.averageGrade.setColor(forGrade: self.section.average)
            } else {
                cell.averageGrade.text = "-"
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GradeCell", for: indexPath) as! GradeCell
            cell.selectionStyle = .none
            
            let grade = self.section.grades.filter({ $0.type == 0 })[indexPath.row]
            cell.gradeLabel.setColor(forGrade: grade.mark)
            cell.gradeLabel.text = grade.mark
            cell.descriptionLabel.text = grade.description
            cell.countLabel.text = "Telt \(self.section.grades[indexPath.row].count) keer mee"
            
            return cell
            
        default:
            ()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Cijfers"
        default:
            ()
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 100
        case 1:
            return 54
        default:
            ()
        }
        return 44
    }
    
}

class GradeInfoCell: UITableViewCell {
    @IBOutlet var averageGrade: UILabel!
}

class GradeCell: UITableViewCell {
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
}
