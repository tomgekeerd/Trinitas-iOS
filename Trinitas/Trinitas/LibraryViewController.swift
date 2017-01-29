//
//  LibraryViewController.swift
//  Trinitas
//
//  Created by Tom de Ruiter on 1/29/17.
//  Copyright © 2017 Rydee. All rights reserved.
//

import UIKit
import Alamofire

class LibraryViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    var refreshSpinner: UIRefreshControl = UIRefreshControl()
    var books = [BookItem]()
    var fee: Fee!
    var libraryUser: LibraryUser!
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.activityView.startAnimating()
        
        // Refresh control setup
        
        self.refreshSpinner = UIRefreshControl()
        self.refreshSpinner.addTarget(self, action: #selector(persistsRefresh), for: .valueChanged)
        self.collectionView.addSubview(self.refreshSpinner)

        self.getData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        
        self.api.getBorrowedBooks { (success, books) in
            if success {
                if let books = books {
                    self.books = books
                    self.collectionView.reloadData()
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
            }
        }
        
        self.api.getFee { (success, fee) in
            if success {
                if let fee = fee {
                    self.fee = fee
                    self.collectionView.reloadData()
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
            }
        }
        
        self.api.getPersonalLibraryDetails { (success, libraryuser) in
            if success {
                if let libraryuser = libraryuser {
                    self.libraryUser = libraryuser
                    self.collectionView.reloadData()
                }
            } else {
                self.present(alertWithTitle: "Er is iets misgegaan...", msg: "Probeer het later opnieuw")
            }
        }
        
    }

    func persistsRefresh() {
        self.getData()
    }
    
    // MARK: - Segue handling

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = sender as? IndexPath, let dest = segue.destination as? BookItemDetailViewController {
            if segue.identifier == "bookInfo" {
                let overdue = self.books.filter({ $0.overdue == true })
                let notoverdue = self.books.filter({ $0.overdue == false })
                if indexPath.section == 0 {
                    dest.bookItem = notoverdue[indexPath.row]
                } else if indexPath.section == 1 {
                    dest.bookItem = overdue[indexPath.row]
                }
            }
        }
        
    }
}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookItemCell", for: indexPath) as! BookItemCell
        var filteredArray: [BookItem]!
        switch indexPath.section {
        case 0:
            filteredArray = self.books.filter({ $0.overdue == false })
            cell.dueLabel.textColor = UIColor.black
            break
        case 1:
            filteredArray = self.books.filter({ $0.overdue == true })
            cell.dueLabel.textColor = UIColor.red
            break
        default:
            ()
        }
        
        cell.title.text = filteredArray[indexPath.row].title
        cell.coverImage.layer.shadowColor = UIColor.black.cgColor
        cell.coverImage.layer.shadowOpacity = 0.65
        cell.coverImage.layer.shadowRadius = 3.0
        cell.coverImage.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        Alamofire.request(filteredArray[indexPath.row].cover, method: .get).response(completionHandler: { (response) in
            if let data = response.data {
                cell.coverImage.image = UIImage(data: data, scale: 1)
            } else {
                
            }
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: filteredArray[indexPath.row].duedate) {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            cell.dueLabel.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView.isHidden = self.books.count == 0 || self.fee == nil || self.libraryUser == nil
        if !self.collectionView.isHidden {
            self.refreshSpinner.endRefreshing()
        }
        switch section {
        case 0:
            return self.books.filter({
                $0.overdue == false
            }).count
        case 1:
            return self.books.filter({
                $0.overdue == true
            }).count
        default:
            ()
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReusableView", for: indexPath) as! HeaderView
        self.updateSectionHeader(withHeader: view, forIndexPath: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0,1:
            return CGSize(width: self.collectionView.frame.size.width, height: 32)
        default:
            ()
        }
        return CGSize(width: 0, height: 0)
    }
    
    func updateSectionHeader(withHeader header: HeaderView, forIndexPath indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            header.titleLabel.text = "Uitgeleend"
        case 1:
            header.titleLabel.text = "Te laat"
        default:
            ()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "bookInfo", sender: indexPath)
    }
    
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0,1:
            return CGSize(width: 155, height: 215)
        default:
            ()
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0,1:
            return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        default:
            ()
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}



class LibraryInfoCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var feeLabel: UILabel!
    @IBOutlet var numberOfItems: UILabel!
}

class BookItemCell: UICollectionViewCell {
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var dueLabel: UILabel!
}

class HeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
}
