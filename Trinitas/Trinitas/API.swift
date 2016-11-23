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
    
    var baseURL = "https://tomderuiter.com/trinitas/v1/login"

    func login(username: String, password: String, completion: @escaping (_ result: Bool) -> Void) {
        
        let parameters: Parameters = [
            "lln": "\(username)",
            "pass": "\(password)"
        ]
        
        
        Alamofire.request(baseURL, method: .post, parameters: parameters).responseData { (response) in

            if let data = response.data {
                let json = JSON(data: data)
                completion(json["success"].boolValue)
                
            }

        }
        
    }
    
}
