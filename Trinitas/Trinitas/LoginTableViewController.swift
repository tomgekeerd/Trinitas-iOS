
//
//  LoginTableViewController.swift
//  Trinitas
//
//  Created by Tom de ruiter on 20/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class LoginTableViewController: UITableViewController {
    
    let api = API()
    let dh = DataHelper()

    private let tableHeaderHeight: CGFloat = 300.0
    private let cutAway: CGFloat = 90
    
    var currentSelectedTextField: UITextField!
    var originialContentInset: UIEdgeInsets!
    
    var headerMaskLayer: CAShapeLayer!
    var headerView: UIView!
    
    @IBOutlet var frontImage: UIImageView!
    @IBOutlet var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    
        // Set tableview
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        // Set blur
        
        self.frontImage.image = self.frontImage.image?.blur(28)
        self.headerView.bringSubview(toFront: logoImage)
        
        // Set insets
        
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()

    }
    
    func userIsDoneLoggingIn(success: Bool, user: User) {
        
        if success {
            
            // Save user credentials
            
            dh.userNeedsUpdate(user: user)
            
            // Load vc
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarMenu")
            if let tab = vc {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = tab
            }
            
        } else {
            
            // Dipslay error
            
            let controller = UIAlertController(title: "Er is een fout opgetreden", message: "Je gebruikersnaam of wachtwoord in incorrect ingevoerd", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(ok)
            
            if let contr = UIApplication.topViewController() {
                contr.present(controller, animated: true, completion: nil)
            }

        }
        
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        if tableView.contentOffset.y < -tableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
        
        let diff = self.view.frame.size.width / 3
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height - cutAway))
        path.addLine(to: CGPoint(x: diff, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - cutAway))
        headerMaskLayer?.path = path.cgPath
        
        self.originialContentInset = self.tableView.contentInset
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        if self.currentSelectedTextField != nil {
            let pan = self.tableView.panGestureRecognizer.state
            if pan != .possible {
                self.currentSelectedTextField.resignFirstResponder()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!LoginHeaderTableViewCell
        
        // Login button
        
        cell.loginButton.layer.cornerRadius = cell.loginButton.frame.size.height / 2
        
        // Textfields
        
        cell.usernameTextField.delegate = self
        cell.passwordTextField.delegate = self
        
        // Enter credidentials if present

        if let user = dh.user() as? User {
            cell.usernameTextField.text = user.username
            cell.passwordTextField.text = user.password
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height - tableHeaderHeight
    }
    
}

extension LoginTableViewController: UITextFieldDelegate {
    
    // Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentSelectedTextField = textField
    }
    
    // Helpers
    
    func removeKeyboard() {
        if self.currentSelectedTextField != nil {
            self.currentSelectedTextField.resignFirstResponder()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        var userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let idealOrigin = (self.currentSelectedTextField.frame.origin.y + self.currentSelectedTextField.frame.size.height + 15) - keyboardFrame.origin.y
        
        var contentInset: UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = idealOrigin
        
        self.tableView.contentInset = contentInset
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        self.tableView.contentInset = originialContentInset
    }
    
}

class LoginHeaderTableViewCell: UITableViewCell {
    
    let api = API()

    @IBOutlet var loginButton: SLButton!
    @IBOutlet var usernameTextField: ACFloatingTextfield!
    @IBOutlet var passwordTextField: ACFloatingTextfield!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction func loginButtonPressed(sender: UIButton) {
        loginButton.showLoading()

        if let u = usernameTextField.text, let p = passwordTextField.text {
            let user = User(username: u, password: p)
            api.login(user: user) { (success) in
                
                // Load vc
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let login = storyboard.instantiateViewController(withIdentifier: "login") as? LoginTableViewController ?? nil
                
                if let l = login {
                    
                    // Send response to vc
                    
                    l.userIsDoneLoggingIn(success: success, user: user)
                    
                    // Turn button back
                    
                    DispatchQueue.main.async {
                        self.loginButton.hideLoading()
                    }
                    
                }
                
            }

        }
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

