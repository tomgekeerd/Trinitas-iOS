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
    @IBOutlet var activityView: UIActivityIndicatorView!
    var refreshSpinner: UIRefreshControl = UIRefreshControl()
    var mailData = [Mail]()
    let dhh = DataHelperHelpers()
    let api = API()
    var sfViewController: SFSafariViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isHidden = true
        self.activityView.startAnimating()
        
        // Refresh control setup
        
        self.refreshSpinner = UIRefreshControl()
        self.refreshSpinner.addTarget(self, action: #selector(persistsRefresh), for: .valueChanged)
        self.tableView.addSubview(self.refreshSpinner)
        
        // Setup view
        
        let setupMail = self.userDidSetupMail()
        self.setView(setup: setupMail)

        if !setupMail {
            
            self.setupButton.layer.cornerRadius = self.setupButton.frame.size.height / 2
            NotificationCenter.default.addObserver(self, selector: #selector(grantedViewControllerFinished(notification:)), name: Notification.Name(rawValue: "MailUpdate"), object: nil)
            
        } else {
            
            self.api.getItslearningMail(auth_code: nil, completion: { (success, data) in
                
                if success {
                    if let d = data {
                        self.mailData = d
                        self.tableView.reloadData()
                    }
                } else {
                    
                }
                
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View methods
    
    func setView(setup: Bool) {
        
        if setup {
            
            self.setupButton.isHidden = true
            self.setupLabel.isHidden = true
            self.activityView.isHidden = false
            
        } else {
            
            self.setupButton.isHidden = false
            self.setupLabel.isHidden = false
            self.activityView.isHidden = true

        }
        
    }
    
    // MARK: - Helper methods
    
    func userDidSetupMail() -> Bool {
        return UserDefaults().bool(forKey: "setupMail")
    }
    
    func persistsRefresh() {
        
        self.api.getItslearningMail(auth_code: nil, completion: { (success, data) in
            
            self.refreshSpinner.endRefreshing()
            
            if success {
                if let d = data {
                    self.mailData = d
                    self.tableView.reloadData()
                }
            } else {
                
            }
            
        })
        
    }
    
    // MARK: - IBActions
    
    @IBAction func showSetupMail() {
        
        if let url = URL(string: "https://trinitas.itslearning.com/oauth2/authorize.aspx?client_id=10ae9d30-1853-48ff-81cb-47b58a325685&state=state&response_type=code&redirect_uri=itsl-itslearning://login&scope=SCOPE") {
            self.sfViewController = SFSafariViewController(url: url)
            self.sfViewController.delegate = self
            self.present(self.sfViewController, animated: true, completion: nil)
        }

    }
    
    // MARK: - Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mailDetails" {
            if let dest = segue.destination as? MailDetailViewController, let indexPath = sender as? IndexPath {
                dest.mail = self.mailData[indexPath.row]
            }
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
        
        let mail = self.mailData[indexPath.row]
        
        // Set texts in cell
        
        cell.descriptionOfMsg.text = mail.preview_text
        cell.sender.text = mail.from.first_name + " " + mail.from.last_name
        
        // Set subject
        
        if let sub = mail.subject {
            if sub.characters.count > 0 {
                cell.subject.text = sub
            } else {
                cell.subject.text = "Geen onderwerp"
            }
        }
        
        // Set date

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dateFormatter.date(from: mail.date) {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let formattedDate = dateFormatter.string(from: date)
            cell.dateOfMsg.text = formattedDate
        }
        
        // Set read
        
        if mail.read {
            cell.contentView.alpha = 0.65
        } else {
            cell.contentView.alpha = 1.0
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.isHidden = self.mailData.count <= 0
        return self.mailData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "mailDetails", sender: indexPath)
    }
    
}

// MARK: - MailCell

class MailCell: UITableViewCell {
    @IBOutlet var sender: UILabel!
    @IBOutlet var descriptionOfMsg: UILabel!
    @IBOutlet var subject: UILabel!
    @IBOutlet var dateOfMsg: UILabel!
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
            
            // Save token & get mail
            
            self.api.getItslearningMail(auth_code: code, completion: { (success, data) in
                
            })
            
            // Dismiss the OAuth controller
            
            self.sfViewController.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}
