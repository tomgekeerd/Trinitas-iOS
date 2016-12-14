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
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TeacherCell
            
            if let c = cell as? TeacherCell {
                
                if let data = self.lessonData {
                    
                    c.lessonData = data
                    
                }
            }
            
            break
        case 1:
            break
            
        default:()
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
