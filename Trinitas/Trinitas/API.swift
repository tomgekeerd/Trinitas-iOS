//
//  API.swift
//  Trinitas
//
//  Created by Tom de ruiter on 20/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Money

class API: NSObject {
    
    var sheduleLoop = DispatchGroup()
    var baseURL = "https://tomderuiter.com/trinitas/v1/"
    var baseILURL = "https://trinitas.itslearning.com/restapi/"
    var baseALURL = "https://trinitascollege.auralibrary.nl/"
    let dh = DataHelper()
    let dhh = DataHelperHelpers()
    
    // MARK: - TriniAPI
    
    func login(user: User, completion: @escaping (_ result: Bool) -> Void) {
        
        // Initialize params
        
        let parameters: Parameters = [
            "lln": user.username,
            "pass": user.password
        ]
        
        // Request login
        
        Alamofire.request(baseURL + "login", method: .post, parameters: parameters).responseData { (response) in

            switch response.result {
            case .success:
                
                if let data = response.data {
                    let json = JSON(data: data)
                    completion(json["success"].boolValue)
                }

                break
                
            case .failure(let error):
                
                completion(false)
                print(error)
                
                break
                
            }
            
        }
        
    }
    
    func getScheduleOfDay(day: Date, forced: Bool, completion: @escaping (_ success: Bool, _ fromDB: Bool, _ callback: [Lesson]) -> Void) {
        
        let needsUpdate = dh.needsUpdate(date: day, forced: forced)
        if needsUpdate {
            
            if let user = dh.user() {
                
                // Get string date of startDate
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dateString = dateFormatter.string(from: day)
                
                // Initialize params
                
                let parameters: Parameters = [
                    "lln": user.username,
                    "pass": user.password,
                    "sd": dateString
                ]
                
                // Request schedule
                
                Alamofire.request(baseURL + "schedule", method: .post, parameters: parameters).responseData { (response) in
                    
                    // Call completion when data is sent to CoreData
                    
                    switch response.result {
                    case .success:
                        if let data = response.data {
                            let json = JSON(data: data)
                            if let success = json["success"].bool {
                                if success == true {
                                    
                                    // Set schedule in data
                                    
                                    self.dh.scheduleNeedsUpdate(json: json, day: day, completion: { (results) in
                                        completion(true, false, results)
                                    })
                                    
                                } else if success == false {
                                    
                                    if json["err"].intValue == 202 {
                                        
                                        self.getScheduleOfDay(day: day, forced: forced, completion: completion)
                                        
                                    } else {
                                        
                                        completion(false, false, [])
                                        
                                    }
                                    
                                }
                            }
                        }
                        break
                        
                    case .failure:
                        
                        // Error occurred (probably wifi lost), load last updated data in db
                        
                        self.dh.scheduleData(date: day, completion: { (results) in
                            completion(true, true, results)
                        })
                        
                        break
                        
                    }
                    
                }
                
            }
            
        } else {
            
            self.dh.scheduleData(date: day, completion: { (results) in
                completion(true, true, results)
            })
            
        }
            
    }
    
    // MARK: - Grades
    
    func getGrades(completion: @escaping (_ success: Bool, _ data: [GradePeriod]?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {

            // Initialize params
            
            let parameters: Parameters = [
                "lln": user.username,
                "pass": user.password
            ]
            
            // Request login
            
            Alamofire.request(baseURL + "numbers", method: .post, parameters: parameters).responseData { (response) in
                
                switch response.result {
                case .success:
                    print(String(data: response.data!, encoding: .utf8))
                    if let data = response.data {
                        let json = JSON(data: data)
                        if json["success"].boolValue == true {
                            let gradeData = self.dh.getGradesData(withJsonData: json)
                            completion(true, gradeData)
                        } else {
                            completion(false, nil)
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    
                    completion(false, nil)
                    print(error)
                    
                    break
                    
                }
                
            }
            
        } else {
            completion(false, nil)
        }

    }
    
    func getExamGrades(completion: @escaping (_ success: Bool, _ grades: [GradePeriod]?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            // Initialize params
            
            let parameters: Parameters = [
                "lln": user.username,
                "pass": user.password
            ]
            
            // Request login
            
            Alamofire.request(baseURL + "exam_numbers", method: .post, parameters: parameters).responseData { (response) in
                
                switch response.result {
                case .success:
                    
                    if let data = response.data {
                        let json = JSON(data: data)
                        if json["success"].boolValue == true {
                            let gradeData = self.dh.getGradesData(withJsonData: json)
                            completion(true, gradeData)
                        } else {
                            completion(false, nil)
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    
                    completion(false, nil)
                    print(error)
                    
                    break
                    
                }
                
            }
            
        } else {
            completion(false, nil)
        }
        
    }
    
    // MARK: - Library
    
    func getLibraryId(completion: @escaping (_ success: Bool, _ id: String?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            // Initialize params
            
            let parameters: Parameters = [
                "lln": user.username,
                "pass": user.password
            ]
            
            // Request login
            
            Alamofire.request(baseURL + "m_id", method: .post, parameters: parameters).responseData { (response) in
                
                switch response.result {
                case .success:
                    
                    if let data = response.data {
                        let json = JSON(data: data)
                        if json["success"].boolValue == true {
                            if let id = json["id"].string {
                                completion(true, id)
                            }
                        } else {
                            completion(false, nil)
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    
                    completion(false, nil)
                    print(error)
                    
                    break
                    
                }
                
            }
            
        } else {
            completion(false, nil)
        }

    }
    
    func extendBook(withItemId id: String, completion: @escaping (_ success: Bool, _ msg: String?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            if let libraryId = self.dhh.retrieveLibraryId() {
                
                // Initialize params
                
                let parameters: Parameters = [
                    "id": user.username,
                    "auth": libraryId,
                    "itemid": id
                ]
                
                // Request login
                
                Alamofire.request(baseALURL + "extend.ashx", method: .get, parameters: parameters).responseData { (response) in
                    
                    switch response.result {
                    case .success:
                        
                        if let data = response.data {
                            let json = JSON(data: data)
                            completion(json["success"].boolValue, json["msg"].stringValue)
                        } else {
                            completion(false, nil)
                        }
                        
                        break
                    case .failure(let error):
                        
                        completion(false, nil)
                        print(error)
                        
                        break
                        
                    }
                    
                }
                
            } else {
                
                self.getLibraryId(completion: { (success, id) in
                    if success {
                        if let id = id {
                            self.dhh.saveLibraryId(withId: id)
                            self.extendBook(withItemId: id, completion: completion)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                })
                
            }
            
        } else {
            completion(false, nil)
        }

    }
    
    func getPersonalLibraryDetails(completion: @escaping (_ success: Bool, _ libraryUser: LibraryUser?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            // Initialize params
            
            let parameters: Parameters = [
                "id": user.username,
                "password": user.password
            ]
            
            // Request login
            
            Alamofire.request(baseALURL + "amLogin.ashx", method: .get, parameters: parameters).responseData { (response) in
                
                switch response.result {
                case .success:
                    
                    if let data = response.data {
                        let json = JSON(data: data)
                        if let name = json["name"].string,
                            let email = json["email"].string,
                            let accountid = json["accountid"].string {
                            
                            self.getLibraryProfilePicture(completion: { (success, image) in
                                if success {
                                    if let img = image {
                                        let libraryUser = LibraryUser(name: name,
                                                                      accountId: accountid,
                                                                      email: email,
                                                                      profile: img)
                                        completion(true, libraryUser)
                                    } else {
                                        completion(false, nil)
                                    }

                                } else {
                                    completion(false, nil)
                                }
                            })
                            
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                    break
                case .failure(let error):
                    
                    completion(false, nil)
                    print(error)
                    
                    break
                    
                }
                
            }
        
        } else {
            completion(false, nil)
        }

    }
    
    func getFee(completion: @escaping (_ success: Bool, _ fee: Fee?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            if let libraryId = self.dhh.retrieveLibraryId() {
                
                // Initialize params
                
                let parameters: Parameters = [
                    "id": user.username,
                    "auth": libraryId
                ]
                
                // Request login
                
                Alamofire.request(baseALURL + "getFee.ashx", method: .get, parameters: parameters).responseData { (response) in
                    
                    switch response.result {
                    case .success:
                        
                        if let data = response.data {
                            let json = JSON(data: data)
                            if let overdueFee = json["overduefee"].string,
                                let remainingFee = json["remainingfee"].string {
                                
                                var overdueFee = overdueFee.replacingOccurrences(of: ",", with: ".")
                                overdueFee = overdueFee.replacingOccurrences(of: "EUR ", with: "")
                                
                                var remainingFee = remainingFee.replacingOccurrences(of: ",", with: ".")
                                remainingFee = remainingFee.replacingOccurrences(of: "EUR ", with: "")
                                
                                let total: EUR = EUR(overdueFee.doubleValue + remainingFee.doubleValue)
                                
                                let fee = Fee(overdueFee: overdueFee,
                                              remainingFee: remainingFee,
                                              totalFee: total)
                                completion(true, fee)
                                
                            }
                        } else {
                            completion(false, nil)
                        }
                        
                        break
                    case .failure(let error):
                        
                        completion(false, nil)
                        print(error)
                        
                        break
                        
                    }
                    
                }
                
            } else {
                
                self.getLibraryId(completion: { (success, id) in
                    if success {
                        if let id = id {
                            self.dhh.saveLibraryId(withId: id)
                            self.getFee(completion: completion)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                })
                
            }
            
        } else {
            completion(false, nil)
        }
        
    }
    
    func getBorrowedBooks(completion: @escaping (_ success: Bool, _ bookData: [BookItem]?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            if let libraryId = self.dhh.retrieveLibraryId() {
                
                // Initialize params
                
                let parameters: Parameters = [
                    "id": user.username,
                    "auth": libraryId
                ]
                
                // Request login
                
                Alamofire.request(baseALURL + "getBorrowed.ashx", method: .get, parameters: parameters).responseData { (response) in
                    
                    switch response.result {
                    case .success:
                        
                        if let data = response.data, let json = JSON(data: data).array {
                            let books = self.dh.getBooksData(fromJsonData: json)
                            completion(true, books)
                        } else {
                            completion(false, nil)
                        }
                        
                        break
                    case .failure(let error):
                        
                        completion(false, nil)
                        print(error)
                        
                        break
                        
                    }
                    
                }

            } else {
                
                self.getLibraryId(completion: { (success, id) in
                    if success {
                        if let id = id {
                            self.dhh.saveLibraryId(withId: id)
                            self.getBorrowedBooks(completion: completion)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                })
                
            }
            
        } else {
            completion(false, nil)
        }

    }
    
    func getBook(withItemId itemid: String, completion: @escaping (_ success: Bool, _ book: Book?) -> Void) {
        
        // Initialize params
        
        let parameters: Parameters = [
            "itemid": itemid
        ]
        
        // Request login
        
        Alamofire.request(baseALURL + "getItem.ashx", method: .get, parameters: parameters).responseData { (response) in
            
            switch response.result {
            case .success:
                
                if let data = response.data {
                    let json = JSON(data: data)
                    if let book = self.dh.getBookData(fromJsonData: json) {
                        completion(true, book)
                    } else {
                        completion(false, nil)
                    }
                } else {
                    completion(false, nil)
                }
                
                break
            case .failure(let error):
                
                completion(false, nil)
                print(error)
                
                break
                
            }
            
        }

    }
    
    func getLibraryProfilePicture(completion: @escaping (_ success: Bool, _ profile: UIImage?) -> Void) {
        
        // Get user
        
        if let user = dh.user() {
            
            if let libraryId = self.dhh.retrieveLibraryId() {
                
                // Initialize params
                
                let parameters: Parameters = [
                    "id": user.username,
                    "auth": libraryId
                ]
                
                // Request login
                
                Alamofire.request(baseALURL + "getPhoto.ashx", method: .get, parameters: parameters).responseData { (response) in
                    
                    switch response.result {
                    case .success:
                        
                        if let data = response.data {
                            let image = UIImage(data: data, scale: 1.0)
                            completion(true, image)
                        } else {
                            completion(false, nil)
                        }
                        
                        break
                    case .failure(let error):
                        
                        completion(false, nil)
                        print(error)
                        
                        break
                        
                    }
                    
                }
                
            } else {
                
                self.getLibraryId(completion: { (success, id) in
                    if success {
                        if let id = id {
                            self.dhh.saveLibraryId(withId: id)
                            self.getLibraryProfilePicture(completion: completion)
                        } else {
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                })
                
            }
            
        } else {
            completion(false, nil)
        }
        
    }
    
    // MARK: - Itslearning RESTAPI
    
    func getMail(withMail mail: Mail, completion: @escaping (_ success: Bool, _ data: Mail?) -> Void) {
        
        // Get refreshtoken
        
        if let refresh_token = self.dhh.retrieveRefreshToken() {
            
            self.getItslearningToken(withCode: refresh_token, auth_code: false, completion: { (success, access_token) in
                
                if success {
                    
                    if let at = access_token {
                        
                        let params: [String: Any] = [
                            "MessageId": mail.message_id,
                            "IsRead": true
                        ]
                        
                        Alamofire.request(self.baseILURL + "personal/messages/\(mail.message_id)/v1?access_token=\(at)", method: .put, parameters: params, encoding: JSONEncoding.default).responseData { (response) in
                            
                            switch response.result {
                            case .success:
                                
                                if let data = response.data {
                                    
                                    let json = JSON(data: data)
                                    if let toArray = json["To"].array, let text = json["Text"].string {
                                        let personData = self.dh.getPersons(withJsonData: toArray)
                                        var m = mail
                                        m.to = personData
                                        m.text = text
                                        
                                        completion(true, m)
                                    }
                                    
                                }
                                
                                break
                                
                            case .failure:
                                
                                completion(false, nil)
                                
                                break
                                
                            }
                            
                        }

                        
                    }
                    
                } else {
                    completion(false, nil)
                }
                
            })
            
        } else {
            completion(false, nil)
        }
        
    }
    
    func getItslearningMail(auth_code: String?, completion: @escaping (_ success: Bool, _ data: [Mail]?) -> Void) {
        
        // Get refreshToken
        
        var code = ""
        if let auth = auth_code {
            code = auth
        } else if let refresh_token = self.dhh.retrieveRefreshToken() {
            code = refresh_token
        }
        
        if code.characters.count > 0 {
        
            self.getItslearningToken(withCode: code, auth_code: auth_code != nil, completion: { (success, access_token) in
                
                if success {
                    
                    if let at = access_token {
                        
                        let params = [
                            "access_token": at
                        ]
                        
                        Alamofire.request(self.baseILURL + "personal/messages/v1", method: .get, parameters: params).responseData { (response) in
                            
                            switch response.result {
                            case .success:
                                
                                if let data = response.data {
                                    
                                    let json = JSON(data: data)
                                    if let jsonData = json["EntityArray"].array {
                                        let mailData = self.dh.getMails(withJsonData: jsonData)
                                        completion(true, mailData)
                                    } else {
                                        completion(false, nil)
                                    }

                                }
                                
                                break
                                
                            case .failure:
                                
                                completion(false, nil)
                                
                                break
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    completion(false, nil)
                }
            })
            
        } else {
            completion(false, nil)
        }
        
    }

    private func getItslearningToken(withCode code: String, auth_code: Bool, completion: @escaping (_ success: Bool, _ token: String?) -> Void) {
        
        let params = [
            auth_code ? "code" : "refresh_token": code,
            "client_id": "10ae9d30-1853-48ff-81cb-47b58a325685",
            "grant_type": auth_code ? "authorization_code" : "refresh_token"
        ]
        
        // Request itslearning token
        
        Alamofire.request(baseILURL + "oauth2/token", method: .post, parameters: params).responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.data {
                    let json = JSON(data: data)
                    
                    if let at = json["access_token"].string, let rt = json["refresh_token"].string {
                        
                        // Save refreshToken
                        
                        self.dhh.saveRefreshToken(withToken: rt)

                        // Completion
                        
                        completion(true, at)
                    } else {
                        
                        completion(false, nil)
                    }
                    
                }
                break
                
            case .failure:
                
                completion(false, nil)
                
                break
                
            }
            
        }

    }
    
}
