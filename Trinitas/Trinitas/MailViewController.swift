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

    @IBOutlet var setupButton: UIButton!
    @IBOutlet var setupLabel: UILabel!
    var sfViewController: SFSafariViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.setupButton.layer.cornerRadius = self.setupButton.frame.size.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(grantedViewControllerFinished(notification:)), name: Notification.Name(rawValue: "MailUpdate"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setupView(setup: Bool) {
        
        if setup {
            
            self.setupButton.isHidden = false
            self.setupLabel.isHidden = false
            
        } else {
            
            self.setupButton.isHidden = true
            self.setupLabel.isHidden = true
            
        }
        
    }
    
    @IBAction func showSetupMail() {
        
        if let url = URL(string: "https://trinitas.itslearning.com/oauth2/authorize.aspx?client_id=10ae9d30-1853-48ff-81cb-47b58a325685&state=state&response_type=code&redirect_uri=itsl-itslearning://login&scope=SCOPE") {
            self.sfViewController = SFSafariViewController(url: url)
            self.sfViewController.delegate = self
            self.present(self.sfViewController, animated: true, completion: nil)
        }

    }

}

extension MailViewController: SFSafariViewControllerDelegate {
    
    // MARK: - Get finish
    
    func grantedViewControllerFinished(notification: NSNotification) {
        if let code = notification.object as? String {
            self.sfViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}
