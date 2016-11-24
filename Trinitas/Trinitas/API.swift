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
    
    var baseURL = "https://tomderuiter.com/trinitas/v1/"
    let dh = DataHelper()
    
    func login(user: User, completion: @escaping (_ result: Bool) -> Void) {
        
        // Initialize params
        
        let parameters: Parameters = [
            "lln": user.username,
            "pass": user.password
        ]
        
        // Request login
        
        Alamofire.request(baseURL + "login", method: .post, parameters: parameters).responseData { (response) in

            if let data = response.data {
                let json = JSON(data: data)
                completion(json["success"].boolValue)
            }

        }
        
    }
    
    func getScheduleOfWeek(user: User, startDate: Date, completion: @escaping (_ result: Bool) -> Void) {
        
        // Get string date of startDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: startDate)
        
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
                        self.dh.scheduleNeedsUpdate(json: json)
                    }
                    completion(true)
                break

                case .failure(let error):
                    completion(false)
                    fatalError(error as! String)
                break
                
            }
            
        }

    }
    
}
