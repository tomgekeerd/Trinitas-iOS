//
//  MailViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/21/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit
import SafariServices

class MailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var setupButton: UIButton!
    @IBOutlet var setupLabel: UILabel!
    var sfViewController: SFSafariViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let setupMail = self.userDidSetupMail()
        self.setView(setup: setupMail)

        if !setupMail {
            
            self.setupButton.layer.cornerRadius = self.setupButton.frame.size.height / 2
            NotificationCenter.default.addObserver(self, selector: #selector(grantedViewControllerFinished(notification:)), name: Notification.Name(rawValue: "MailUpdate"), object: nil)
            
        } else {
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View methods
    
    func setView(setup: Bool) {
        
        if setup {
            
            self.tableView.isHidden = false
            self.setupButton.isHidden = true
            self.setupLabel.isHidden = true
            
        } else {
            
            self.tableView.isHidden = true
            self.setupButton.isHidden = false
            self.setupLabel.isHidden = false
            
        }
        
    }
    
    // MARK: - Helper methods
    
    func userDidSetupMail() -> Bool {
        return UserDefaults().bool(forKey: "setupMail")
    }
    
    // MARK: - IBActions
    
    @IBAction func showSetupMail() {
        
        if let url = URL(string: "https://trinitas.itslearning.com/oauth2/authorize.aspx?client_id=10ae9d30-1853-48ff-81cb-47b58a325685&state=state&response_type=code&redirect_uri=itsl-itslearning://login&scope=SCOPE") {
            self.sfViewController = SFSafariViewController(url: url)
            self.sfViewController.delegate = self
            self.present(self.sfViewController, animated: true, completion: nil)
        }

    }

}

// MARK: - UITableViewDelegate

extension MailViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension MailViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MailCell
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

// MARK: - MailCell

class MailCell: UITableViewCell {
    
}

// MARK: - SFSafariViewControllerDelegate

extension MailViewController: SFSafariViewControllerDelegate {
    
    // MARK: - Get finish
    
    func grantedViewControllerFinished(notification: NSNotification) {
        
        // Check for data (refresh token)
        
        if let code = notification.object as? String {
            
            // Set userdefault boolean
            
            UserDefaults().set(true, forKey: "setupMail")
            UserDefaults().synchronize()
            
            // Dismiss the OAuth controller
            
            self.sfViewController.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}
