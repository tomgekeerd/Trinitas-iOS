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
    var books = [BookItem]()
    let api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookItemCell", for: indexPath) as! BookItemCell
        var filteredArray: [BookItem]!
        switch indexPath.section {
        case 0:
            filteredArray = self.books.filter({ $0.overdue == false })
            break
        case 1:
            filteredArray = self.books.filter({ $0.overdue == true })
            break
        default:
            ()
        }
        
        cell.title.text = filteredArray[indexPath.row].title
        Alamofire.request(filteredArray[indexPath.row].cover, method: .get).response(completionHandler: { (response) in
            if let data = response.data {
                cell.coverImage.image = UIImage(data: data, scale: 1)
            } else {
                
            }
        })
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView.isHidden = self.books.count == 0
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
    
}

class BookItemCell: UICollectionViewCell {
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var title: UILabel!
}

class HeaderView: UICollectionReusableView {
    @IBOutlet var titleLabel: UILabel!
}
