//
//  MoreViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/30/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var refreshSpinner: UIRefreshControl = UIRefreshControl()
    let api = API()
    var fee: Fee!
    var libraryUser: LibraryUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Refresh control
        
        self.refreshSpinner = UIRefreshControl()
        self.refreshSpinner.addTarget(self, action: #selector(getData), for: .valueChanged)
        self.tableView.addSubview(self.refreshSpinner)

        // Get data
        
        self.getData()
        
    }
    
    func getData() {
        
        self.api.getFee { (success, fee) in
            if success {
                if let fee = fee {
                    self.fee = fee
                    self.tableView.reloadData()
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
            }
        }
        
        self.api.getPersonalLibraryDetails { (success, libraryuser) in
            if success {
                if let libraryuser = libraryuser {
                    self.libraryUser = libraryuser
                    self.tableView.reloadData()
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
            }
        }

    }

}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            
            if let details = self.libraryUser, let fee = self.fee {
                cell.emailLabel.text = details.email
                cell.profileImage.image = details.profile
                cell.profileImage.contentMode = .scaleAspectFill
                cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
                cell.profileImage.clipsToBounds = true
                cell.feeLabel.text = "Boete: \(fee.totalFee)"
                cell.nameLabel.text = details.name
                
                if fee.totalFee > 0.00 {
                    cell.feeLabel.textColor = UIColor.red
                }
            }
                        
            return cell
            
        default:
            ()
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}

class ProfileCell: UITableViewCell {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var feeLabel: UILabel!
}
