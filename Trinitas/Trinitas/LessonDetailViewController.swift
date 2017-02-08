//
//  LessonDetailViewController.swift
//  Trinitas
//
//  Created by Tom de ruiter on 14/12/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit

class LessonDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var lessonData: Lesson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar setup color
        
        if let nav = self.navigationController {
            nav.navigationBar.tintColor = UIColor.white
        }
        
        // UITableView setup
        
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup UIStatusBarStyle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
        
    }

}

extension LessonDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource & Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell = UITableViewCell()
        
        switch indexPath.row {
            
        case 0:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath) as! TeacherCell
            
            if let c = cell as? TeacherCell {
                
                if let data = self.lessonData {
                    
                    c.lessonData = data
                    
                }
            }
            
            break
        case 1:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "homeworkCell", for: indexPath) as! HomeworkTableViewCell
            
            if let c = cell as? HomeworkTableViewCell {
                
                c.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);

                if let data = self.lessonData {

                    // Set test
                    
                    if let testL = c.testLabel {
                        
                        if let test = data.test {
                            
                            testL.text = "Toets: " + (test ? "ja" : "nee")

                        }

                    }
                    
                    // Set homework
                    
                    if let homeworkL = c.homeworkLabel {
                        
                        if let homework = data.homework {
                            
                            homeworkL.text = "Huiswerk: " + (homework ? "ja" : "nee")
                            
                        }
                        
                    }
                    
                    // Set homework description
                    
                    if let homeworkTv = c.homeworkDescription {
                        
                        if let homeworkDescription = data.homeworkDescription {
                            
                            homeworkTv.text = homeworkDescription
                            
                        }
                        
                    }
                    
                    // Set height of homework description
                    
                    let contentSize = c.homeworkDescription.sizeThatFits(c.homeworkDescription.bounds.size)
                    c.homeworkDescription.frame.size = contentSize
                    
                }
                
            }

            break
            
        default:()
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            
            return self.view.frame.size.height - 64 * 2
            
        }
        
        return 64
        
    }
    
}
