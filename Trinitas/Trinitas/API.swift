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

class API: NSObject {
    
    var sheduleLoop = DispatchGroup()
    var baseURL = "https://tomderuiter.com/trinitas/v1/"
    var baseILURL = "https://trinitas.itslearning.com/restapi/"
    let dh = DataHelper()
    
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
    
    // MARK: - Itslearning RESTAPI
    
    func getItslearningToken(withCode code: String, completion: @escaping (_ success: Bool, _ token: String?) -> Void) {
        
        let params = [
            "code": code,
            "client_id": "10ae9d30-1853-48ff-81cb-47b58a325685",
            "grant_type": "authorization_code"
        ]
        
        // Request itslearning token
        
        Alamofire.request(baseILURL + "oauth2/token", method: .post, parameters: params).responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.data {
                    let json = JSON(data: data)

                    if json.count > 0 {
            
                        if let at = json["access_token"].string, let rt = json["refresh_token"].string {
                            completion(true, at)
                        }
                        
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
