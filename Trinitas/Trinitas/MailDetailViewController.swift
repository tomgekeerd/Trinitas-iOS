//
//  MailDetailViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/25/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit

class MailDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    var mail: Mail!
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.activityView.startAnimating()
        
        if let mail = self.mail {
            
            self.api.getMail(withMail: mail, completion: { (success, m) in
                self.mail = m
                self.tableView.reloadData()
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MailDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell", for: indexPath) as! RecipientMailCell
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = self.mail.text == nil
        return 1
    }
    
}

class RecipientMailCell: UITableViewCell {
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
}
