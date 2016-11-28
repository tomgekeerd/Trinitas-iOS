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

struct Lesson {
    
    // Required
    
    var day: String!
    var type: String!
    var hour: Int!
    
    // Optional
    
    var lessonGroup: String? = nil
    var teacher: String? = nil
    var teacherSmall: String? = nil
    var teacherTitle: String? = nil
    var lessonTitle: String? = nil
    var homeworkDescription: String? = nil
    var room: String? = nil

    var start: Int? = nil
    var end: Int? = nil
    var week_no: Int? = nil
    
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
        
        let key = KeychainWrapper()
        key.mySetObject(user.username, forKey: kSecAttrAccount)
        key.mySetObject(user.password, forKey: kSecValueData)
        key.writeToKeychain()
        
    }
    
    func user() -> Any? {
        
        let key = KeychainWrapper()
        if let u = key.myObject(forKey: kSecAttrAccount) as? String, let p = key.myObject(forKey: kSecValueData) as? String {
            return User(username: u, password: p)
        } else {
            return nil
        }

    }
    
    // Schedule
    
    func scheduleData(startDate: Date, completion: @escaping (_ results: [Lesson]) -> Void) {
        
        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            let fetchCount = NSFetchRequest<NSFetchRequestResult>()
            
            if let e = entity {
                
                // Date formatting...
                
                if let w_no = helpers.getWeek(today: startDate) {
                    
                    // Set fetch request...
                    
                    fetchCount.entity = e
                    let predicate = NSPredicate(format: "week_no = %i", w_no)
                    fetchCount.predicate = predicate
                    
                    do {
                        
                        if let results = try managedContext.fetch(fetchCount) as? [Lessons] {
                            
                            var callback = [Lesson]()
                            for result in results {
                                
                                let lesson = Lesson(day: result.day,
                                                    type: result.type,
                                                    hour: Int(result.hour),
                                                    lessonGroup: result.group,
                                                    teacher: result.teacher,
                                                    teacherSmall: result.teacher_small,
                                                    teacherTitle: result.teacher_title,
                                                    lessonTitle: result.title,
                                                    homeworkDescription: result.homework_description,
                                                    room: result.room,
                                                    start: Int(result.start),
                                                    end: Int(result.end),
                                                    week_no: Int(result.week_no),
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
    }
    
    // Save data to coreData 
    
    func scheduleNeedsUpdate(json: JSON) {
        
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
                let predicate = NSPredicate(format: "week_no = %i", json["w_no"].intValue)
                fetchRequest.predicate = predicate
                
                var fetchResults = [Lessons]()
                do {
                    if let results = try managedContext.fetch(fetchRequest) as? [Lessons] {
                        fetchResults = results
                    }
                } catch {
                    fatalError("Something went wrong fetching...")
                }
                
                // Set values in entity
                
                let allLessons = helpers.getLessonsOfJSON(json: json)
                
                for (index, les) in allLessons.enumerated() {
                    
                    // Had to this weird solution because NSManagedObject does not want to initiate without inserting...
                    
                    if fetchResults.count > 0 {
                        
                        // Already exists, overwrite
                        
                        let f = fetchResults[index]

                        f.setValue(les.day, forKey: "day")
                        f.setValue(les.end, forKey: "end")
                        f.setValue(les.homework, forKey: "homework")
                        f.setValue(les.homeworkDescription, forKey: "homework_description")
                        f.setValue(les.hour, forKey: "hour")
                        f.setValue(les.lessonGroup, forKey: "group")
                        f.setValue(les.lessonTitle, forKey: "title")
                        f.setValue(les.room, forKey: "room")
                        f.setValue(les.start, forKey: "start")
                        f.setValue(les.teacher, forKey: "teacher")
                        f.setValue(les.teacherSmall, forKey: "teacher_small")
                        f.setValue(les.teacherTitle, forKey: "teacher_title")
                        f.setValue(les.test, forKey: "test")
                        f.setValue(les.type, forKey: "type")
                        f.setValue(les.week_no, forKey: "week_no")
                            
                    } else {
                        
                        // Insert new one
                        
                        let lesson = Lessons(entity: e, insertInto: managedContext)
                                                
                        lesson.setValue(les.day, forKey: "day")
                        lesson.setValue(les.end, forKey: "end")
                        lesson.setValue(les.homework, forKey: "homework")
                        lesson.setValue(les.homeworkDescription, forKey: "homework_description")
                        lesson.setValue(les.hour, forKey: "hour")
                        lesson.setValue(les.lessonGroup, forKey: "group")
                        lesson.setValue(les.lessonTitle, forKey: "title")
                        lesson.setValue(les.room, forKey: "room")
                        lesson.setValue(les.start, forKey: "start")
                        lesson.setValue(les.teacher, forKey: "teacher")
                        lesson.setValue(les.teacherSmall, forKey: "teacher_small")
                        lesson.setValue(les.teacherTitle, forKey: "teacher_title")
                        lesson.setValue(les.test, forKey: "test")
                        lesson.setValue(les.type, forKey: "type")
                        lesson.setValue(les.week_no, forKey: "week_no")

                    }
                }
                
                // Save to managedContext 
                
                do {
                    try managedContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
            }
        }
        
    }
    
}

class DataHelperHelpers {
    
    func removeAllLessonsWithWeekId(id: Int) {
        
        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            let fetchRemove = NSFetchRequest<NSFetchRequestResult>()

            if let e = entity {
                
                fetchRemove.entity = e
                let predicate = NSPredicate(format: "week_no = %i", id)
                fetchRemove.predicate = predicate
                
                do {
                    
                    if let objectArray = try managedContext.fetch(fetchRemove) as? [Lessons] {
                        for object in objectArray {
                            managedContext.delete(object)
                        }
                    }
                    
                    try managedContext.save()

                } catch {
                    
                    if let error = error as? String {
                        fatalError(error)
                    }
                    
                }

            }
            
        }

    }
    
    
    // Parse json into Lesson structs
    
    func getLessonsOfJSON(json: JSON) -> [Lesson] {
        
        // Set week
        
        self.setWeek(json: json)
        
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
                
                // Add lesson to the array
                
                let lesson = Lesson(day: course["day"].stringValue,
                                    type: course["afspraakObject"]["type"].stringValue,
                                    hour: course["afspraakObject"]["lesuur"].intValue,
                                    lessonGroup: course["afspraakObject"]["lesgroep"].stringValue,
                                    teacher: course["afspraakObject"]["docent"][0]["achternaam"].stringValue,
                                    teacherSmall: course["afspraakObject"]["docent"][0]["afkorting"].stringValue,
                                    teacherTitle: course["afspraakObject"]["docent"][0]["title"].stringValue,
                                    lessonTitle: course["title"].stringValue,
                                    homeworkDescription: hwDesc,
                                    room: course["afspraakObject"]["lokaal"].stringValue,
                                    start: course["start"].intValue,
                                    end: course["end"].intValue,
                                    week_no: json["w_no"].intValue,
                                    homework: homework,
                                    test: test)
                
                
                lessonArray.append(lesson)
                
            }

        }
        
        return lessonArray
    }
    
    func setWeek(json: JSON) {
        
        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Week", in: managedContext)
            let fetchCount = NSFetchRequest<NSFetchRequestResult>()

            if let e = entity {
                
                // Date formatting...
                
                let w_no = json["w_no"].intValue
                let startDate = getFirstDay(weekNumber: w_no)
                
                // Set fetch request...
                
                fetchCount.entity = e
                let predicate = NSPredicate(format: "week_no = %i", w_no)
                fetchCount.predicate = predicate
                
                // Get fetch count...
                
                var count = 0
                do {
                    let results = try managedContext.fetch(fetchCount)
                    count = results.count
                } catch {
                    fatalError("Something went wrong gathering results...")
                }
                
                if count == 0 {
                
                    // Set values in entity
                    
                    let lesson = Lessons(entity: e, insertInto: managedContext)
                    lesson.setValue(w_no, forKey: "week_no")
                    lesson.setValue(startDate, forKey: "start_date")
                    
                    do {
                        try managedContext.save()
                    } catch {
                        fatalError("Something went wrong saving results...")
                    }
                    
                }
            }
        }
        
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
    
    func getFirstDay(weekNumber: Int) -> String? {
        
        let Calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var dayComponent = DateComponents()
        dayComponent.weekOfYear = weekNumber
        dayComponent.weekday = 1
        dayComponent.year = 2015
        
        var date = Calendar.date(from: dayComponent)
        
        if weekNumber == 1 && Calendar.components(.month, from: date!).month != 1 {
            dayComponent.year = 2014
            date = Calendar.date(from: dayComponent)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return String(dateFormatter.string(from: date!))
        
    }
    
}
