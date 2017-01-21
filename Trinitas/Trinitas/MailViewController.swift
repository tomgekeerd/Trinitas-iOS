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
    
    var safariController: SFSafariViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.setupButton.layer.cornerRadius = self.setupButton.frame.size.height / 2
        
        if let url = URL(string: "") {
            self.safariController = SFSafariViewController(url: url)
            self.safariController.delegate = self
        }
        
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

}

extension MailViewController: SFSafariViewControllerDelegate {
    
}

