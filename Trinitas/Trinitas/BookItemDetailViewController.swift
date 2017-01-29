//
//  BookItemDetailViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/29/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit
import Alamofire

class BookItemDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    var bookItem: BookItem!
    var book: Book!
    let api = API()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.activityView.startAnimating()
        
        if let bitem = self.bookItem {
            self.api.getBook(withItemId: bitem.itemId, completion: { (success, book) in
                if success {
                    if let book = book {
                        self.book = book
                        self.tableView.reloadData()
                    }
                } else {
                    self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
                }
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension BookItemDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let book = self.book {
            
            switch indexPath.section {
            case 0:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoFeatureCell", for: indexPath) as! BookInfoFeatureCell
                
                Alamofire.request(book.cover, method: .get).response(completionHandler: { (response) in
                    if let data = response.data {
                        
                        cell.cover.image = UIImage(data: data, scale: 1)
                        cell.cover.layer.shadowColor = UIColor.black.cgColor
                        cell.cover.layer.shadowOpacity = 0.65
                        cell.cover.layer.shadowRadius = 3.0
                        cell.cover.layer.shadowOffset = CGSize(width: 4, height: 4)
                        
                        cell.bgCover.image = UIImage(data: data, scale: 1)
                        
                        
                        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                        blur.frame = cell.bgCover.frame
                        cell.bgCover.addSubview(blur)
                        
                    } else {
                        
                    }
                })
                
                return cell
                
            case 1:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoTitleCell", for: indexPath) as! BookInfoTitleCell
                cell.titleOfBook.text = book.title
                cell.byLabel.text = "Door: \(book.author)"
                return cell
                
            case 2:
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoRatingCell", for: indexPath) as! BookInfoRatingCell
                cell.numberOfRatingsLabel.text = book.num_ratings == 0 ? "Geen beoordelingen" : "\(String(book.num_ratings)) beoordeling(en)"
                cell.starRatingView.isUserInteractionEnabled = false
                
                if book.num_ratings > 0 {
                    cell.starRatingView.value = CGFloat(book.stars)
                } else {
                    cell.starRatingView.value = 0
                }
                
                return cell
                
            default:
                ()
            }
            
        }
        
        return UITableViewCell()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.isHidden = self.book == nil
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200.0
        case 1:
            return 65.0
        case 2:
            return 35.0
        default:
            ()
        }
        return 44
    }
    
}


class BookInfoFeatureCell: UITableViewCell {
    @IBOutlet var cover: UIImageView!
    @IBOutlet var bgCover: UIImageView!
}

class BookInfoTitleCell: UITableViewCell {
    @IBOutlet var titleOfBook: UILabel!
    @IBOutlet var byLabel: UILabel!
}

class BookInfoRatingCell: UITableViewCell {
    @IBOutlet var numberOfRatingsLabel: UILabel!
    @IBOutlet var starRatingView: SwiftyStarRatingView!
}
