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
    var cellHeight: CGFloat = 0.0
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
        
        if let mail = self.mail, let toPersons = mail.to {

            switch indexPath.row {
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell", for: indexPath) as! RecipientMailCell
                cell.selectionStyle = .none
                
                // From
                
                let fromPerson = mail.from
                cell.fromLabel.text = fromPerson.first_name + " " +  fromPerson.last_name
                
                // To
                
                var toText = ""
                for (i, toPerson) in toPersons.enumerated() {
                    if toPersons.count > 1 {
                        toText = toText + toPerson.first_name + " " + toPerson.last_name + ", "
                    } else if toPersons.count == 1 || i == toPersons.count - 1 {
                       toText = toText + toPerson.first_name + " " + toPerson.last_name
                    }
                }
                cell.toLabel.text = toText
                
                // Date
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                if let date = dateFormatter.date(from: mail.date) {
                    dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
                    cell.dateLabel.text = dateFormatter.string(from: date)
                }
                
                return cell
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
                cell.selectionStyle = .none

                // Set subject
                
                if let sub = mail.subject {
                    if sub.characters.count > 0 {
                        cell.subjectLabel.text = sub
                    } else {
                        cell.subjectLabel.text = "Geen onderwerp"
                    }
                }

                return cell
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MailContentCell", for: indexPath) as! MailContentCell
                cell.selectionStyle = .none
                cell.layoutMargins = UIEdgeInsets.zero
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);

                // Set text
                
                if let contents = mail.text {
                    if contents.characters.count > 0 {
                        let totalText = NSString(format:"<span style=\"font-family: -apple-system; font-size: 16px\">%@</span>", contents)
                        let attrStr = try! NSAttributedString(
                            data: totalText.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!,
                            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                       NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)],
                            documentAttributes: nil)
                        cell.mailContents.isScrollEnabled = false
                        cell.mailContents.attributedText = attrStr

                        let fixedWidth = cell.mailContents.frame.size.width
                        cell.mailContents.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                        let newSize = cell.mailContents.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                        var newFrame = cell.mailContents.frame
                        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
                        cell.mailContents.frame = newFrame
                        
                        self.cellHeight = newFrame.size.height
                        self.tableView(self.tableView, heightForRowAt: indexPath)
                    }
                }
                
                return cell
            default: ()
            }
        
        }
    
        return UITableViewCell()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isHidden = self.mail.text == nil
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 100
        case 1:
            return 44
        case 2:
            if self.cellHeight != 0.0 {
                return self.cellHeight
            } else {
                return 44
            }
        default:
            return 44
        }
    }
    
}


class RecipientMailCell: UITableViewCell {
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}

class SubjectCell: UITableViewCell {
    @IBOutlet var subjectLabel: UILabel!
}

class MailContentCell: UITableViewCell {
    @IBOutlet var mailContents: UITextView!
}
