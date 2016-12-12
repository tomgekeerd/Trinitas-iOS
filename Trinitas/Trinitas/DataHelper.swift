//
//  DataHelper.swift
//  Trinitas
//
//  Created by Tom de ruiter on 24/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import CoreData
import SwiftKeychainWrapper

struct Lesson {
    
    // Required
    
    var day: String!
    var type: String!
    var date: String!
    
    var hour: Int!
    var lastUpdate: Int!

    // Optional
    
    var lessonFormat: String? = nil
    var lessonGroup: String? = nil
    var teacher: String? = nil
    var teacherSmall: String? = nil
    var teacherTitle: String? = nil
    var lessonTitle: String? = nil
    var homeworkDescription: String? = nil
    var room: String? = nil
    
    var start: Int? = nil
    var end: Int? = nil
    
    var homework: Bool? = nil
    var test: Bool? = nil
    
}

struct User {
    
    var username: String!
    var password: String!
    
}

class DataHelper: NSObject {
    
    let helpers = DataHelperHelpers()
    
    // User
    
    func userNeedsUpdate(user: User) {
        
        // Write username & password to keychain...
        
        KeychainWrapper.standard.set(user.username, forKey: String(kSecAttrAccount))
        KeychainWrapper.standard.set(user.password, forKey: String(kSecValueData))
        
    }
    
    func user() -> Any? {
        
        if let u = KeychainWrapper.standard.string(forKey: String(kSecAttrAccount)), let p = KeychainWrapper.standard.string(forKey: String(kSecValueData)) {
            return User(username: u, password: p)
        } else {
            return nil
        }

    }
    
    // Schedule
    
    func scheduleData(date: Date, completion: @escaping (_ results: [Lesson]) -> Void) {
        
        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            let fetchCount = NSFetchRequest<NSFetchRequestResult>()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy"
            let dateStamp = dateFormatter.string(from: date)
            
            if let e = entity {
                
                // Set fetch request...
                
                fetchCount.entity = e
                let predicate = NSPredicate(format: "date = %@", dateStamp)
                fetchCount.predicate = predicate
                
                do {
                    
                    if let results = try managedContext.fetch(fetchCount) as? [Lessons] {
                        
                        var callback = [Lesson]()
                        for result in results {
                            
                            let lesson = Lesson(day: result.day,
                                                type: result.type,
                                                date: result.date,
                                                hour: Int(result.hour),
                                                lastUpdate: Int(result.lastUpdate),
                                                lessonFormat: result.lessonFormat,
                                                lessonGroup: result.group,
                                                teacher: result.teacher,
                                                teacherSmall: result.teacher_small,
                                                teacherTitle: result.teacher_title,
                                                lessonTitle: result.title,
                                                homeworkDescription: result.homework_description,
                                                room: result.room,
                                                start: Int(result.start),
                                                end: Int(result.end),
                                                homework: result.homework,
                                                test: result.test)
                            
                            callback.append(lesson)
                            
                        }
                        
                        completion(callback)
                        
                    }
                    
                } catch {
                    fatalError("Something went wrong gathering results...")
                }
                
            }
            
        }
    }
    
    // Check if a server update is necessary
    
    func needsUpdate(date: Date) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let dateStamp = dateFormatter.string(from: date)
        
        var needsUpdate = false

        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            if let e = entity {
                
                // Set fetchRequest
                
                fetchRequest.entity = e
                let predicate = NSPredicate(format: "date = %@", dateStamp)
                fetchRequest.predicate = predicate
                
                var fetchResults = [Lessons]()
                do {
                    if let results = try managedContext.fetch(fetchRequest) as? [Lessons] {
                        fetchResults = results
                    }
                } catch {
                    fatalError("Something went wrong fetching...")
                }
                
                if fetchResults.count > 0 {
                    
                    for r in fetchResults {
                        
                        // Check if the last update is over 5 min.
                        
                        if Int(r.lastUpdate) > Int(Date().timeIntervalSinceNow + 60 * 5) {
                            needsUpdate = true
                        }
                        
                    }
                    
                } else {
                    
                    needsUpdate = true
                    
                }
            }
            
        }
        
        return needsUpdate
        
    }
    
    // Save data to coreData 
    
    func scheduleNeedsUpdate(json: JSON, day: Date, completion: @escaping ( _ callback: [Lesson]) -> Void) {
        
        // Get AppDelegate

        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()

            if let e = entity {
                
                // Set values in entity
                
                let allLessons = helpers.getLessonsOfJSON(json: json)
                
                for les in allLessons {
                    
                    // Set fetchRequest
                    
                    fetchRequest.entity = e
                    let datePredicate = NSPredicate(format: "date = %@", les.date)
                    let hourPredicate = NSPredicate(format: "hour = %i", les.hour)
                    let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, hourPredicate])
                    fetchRequest.predicate = compoundPredicate
                    
                    var fetchResults = [Lessons]()
                    do {
                        if let results = try managedContext.fetch(fetchRequest) as? [Lessons] {
                            fetchResults = results
                        }
                    } catch {
                        fatalError("Something went wrong fetching...")
                    }

                    // Had to this weird solution because NSManagedObject does not want to initiate without inserting...
                    
                    
                    if fetchResults.count > 0 {
                        
                        // Already exists, overwrite
                        
                        let f = fetchResults[0]

                        f.setValue(les.day, forKey: "day")
                        f.setValue(les.date, forKey: "date")
                        f.setValue(les.lastUpdate, forKey: "lastUpdate")
                        f.setValue(les.end, forKey: "end")
                        f.setValue(les.homework, forKey: "homework")
                        f.setValue(les.homeworkDescription, forKey: "homework_description")
                        f.setValue(les.hour, forKey: "hour")
                        f.setValue(les.lessonFormat, forKey: "lessonFormat")
                        f.setValue(les.lessonGroup, forKey: "group")
                        f.setValue(les.lessonTitle, forKey: "title")
                        f.setValue(les.room, forKey: "room")
                        f.setValue(les.start, forKey: "start")
                        f.setValue(les.teacher, forKey: "teacher")
                        f.setValue(les.teacherSmall, forKey: "teacher_small")
                        f.setValue(les.teacherTitle, forKey: "teacher_title")
                        f.setValue(les.test, forKey: "test")
                        f.setValue(les.type, forKey: "type")
                        
                    } else {
                        
                        // Insert new one
                        
                        let lesson = Lessons(entity: e, insertInto: managedContext)
                                                
                        lesson.setValue(les.day, forKey: "day")
                        lesson.setValue(les.date, forKey: "date")
                        lesson.setValue(les.lastUpdate, forKey: "lastUpdate")
                        lesson.setValue(les.end, forKey: "end")
                        lesson.setValue(les.homework, forKey: "homework")
                        lesson.setValue(les.homeworkDescription, forKey: "homework_description")
                        lesson.setValue(les.hour, forKey: "hour")
                        lesson.setValue(les.lessonFormat, forKey: "lessonFormat")
                        lesson.setValue(les.lessonGroup, forKey: "group")
                        lesson.setValue(les.lessonTitle, forKey: "title")
                        lesson.setValue(les.room, forKey: "room")
                        lesson.setValue(les.start, forKey: "start")
                        lesson.setValue(les.teacher, forKey: "teacher")
                        lesson.setValue(les.teacherSmall, forKey: "teacher_small")
                        lesson.setValue(les.teacherTitle, forKey: "teacher_title")
                        lesson.setValue(les.test, forKey: "test")
                        lesson.setValue(les.type, forKey: "type")

                    }
                    
                    // Save to managedContext
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }

                }
                
                self.scheduleData(date: day, completion: { (callback) in
                    completion(callback)
                })
                
            }
            
        }
        
    }
    
}

class DataHelperHelpers {
    
    // Parse json into Lesson structs
    
    func getLessonsOfJSON(json: JSON) -> [Lesson] {
        
        // Initialize arrays
        
        var lessonArray = [Lesson]()
        var dateArray = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        
        // Loop through days...
        
        for index in 0..<5 {
            
            let key = dateArray[index]
            
            // Loop through the lessons...
            
            for i in 0..<8 {
                
                // Check status of lesson

                let course = json[key][i]
                
                var homework = false
                var test = false
                var hwDesc: String!
                
                if course["afspraakObject"]["huiswerk"].exists() {
                    homework = true
                    test = course["afspraakObject"]["huiswerk"]["toets"].boolValue
                    hwDesc = course["afspraakObject"]["huiswerk"]["omschrijving"].stringValue
                }
                
                let date = course["date"].stringValue
                    
                // Add lesson to the array
                    
                let lesson = Lesson(day: course["day"].stringValue,
                                    type: course["afspraakObject"]["type"].stringValue,
                                    date: date,
                                    hour: course["afspraakObject"]["lesuur"].intValue,
                                    lastUpdate: Int(Date().timeIntervalSinceNow),
                                    lessonFormat: course["lesFormat"].stringValue,
                                    lessonGroup: course["afspraakObject"]["lesgroep"].stringValue,
                                    teacher: course["afspraakObject"]["docent"][0]["achternaam"].stringValue,
                                    teacherSmall: course["afspraakObject"]["docent"][0]["afkorting"].stringValue,
                                    teacherTitle: course["afspraakObject"]["docent"][0]["title"].stringValue,
                                    lessonTitle: course["title"].stringValue,
                                    homeworkDescription: hwDesc,
                                    room: course["afspraakObject"]["lokaal"].stringValue,
                                    start: course["start"].intValue,
                                    end: course["end"].intValue,
                                    homework: homework,
                                    test: test)
                
                lessonArray.append(lesson)
                    
                
                
            }

        }
        
        return lessonArray
    }
    
    func getWeek(today:Date) -> Int? {
        
        let calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        let components = calendar.dateComponents([.weekOfYear], from: today)
        
        return components.weekOfYear
        
    }
    
//    func getAllLessons() {
//       let appDelegate =
//            UIApplication.shared.delegate as! AppDelegate
//
//        let managedContext = appDelegate.managedObjectContext
//
//        //2
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lessons")
//
//        //3
//        do {
//            let results = try managedContext.fetch(fetchRequest)
//            for result in results {
//                if let r = result as? Lessons {
//                    print(r.day)
//                }
//            }
//        } catch let error as NSError {
//                print("Could not fetch \(error), \(error.userInfo)")
//        }
//
//    }
    
    private static func getWeekFirstDay(from sourceDate: Date) -> Date? {
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var sourceComp = sourceDate.components
        var comp = DateComponents()
        comp.weekOfYear = sourceComp.weekOfYear
        comp.weekday = 1
        comp.yearForWeekOfYear = sourceComp.yearForWeekOfYear
        return Calendar.date(from: comp)
    }
    
}

extension Date {
    var components: DateComponents {
        let cal = NSCalendar.current
        return cal.dateComponents(Set([.year, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear, .yearForWeekOfYear]), from: self)
    }
}
