//
//  DataHelper.swift
//  Trinitas
//
//  Created by Tom de ruiter on 24/11/2016.
//  Copyright © 2016 Rydee. All rights reserved.
//

import UIKit
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
    
    var start: Int? = nil
    var end: Int? = nil
    var room: Int? = nil
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
    
    func userNeedsUpdate(user: User) {
        
        // Write username & password to keychain...
        
        let key = KeychainWrapper()
        key.mySetObject(user.username, forKey: kSecAttrAccount)
        key.mySetObject(user.password, forKey: kSecValueData)
        key.writeToKeychain()
        
    }
    
    func scheduleNeedsUpdate(json: JSON) {
        
        // Get AppDelegate

        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity
            
            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Lessons", in: managedContext)
            
            if let e = entity {
                
                // Set values in entity
                let allLessons = helpers.getLessonsOfJSON(json: json)
                
                for les in allLessons {
                    
                    let lesson = NSManagedObject(entity: e, insertInto: managedContext)
                    
                    
                    // If type is 'vrij', dan alleen day, type & hour submitten
                    
                    if les.type != "Vrij" {
                        
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
                        
                    } else {
                        
                        lesson.setValue(les.day, forKey: "day")
                        lesson.setValue(les.type, forKey: "type")
                        lesson.setValue(les.week_no, forKey: "week_no")
                        lesson.setValue(les.hour, forKey: "hour")

                    }
                    
                }
                
                do {
                    try managedContext.save()
                    self.helpers.getLessons()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
                
            }
        }
        
    }
    
}

class DataHelperHelpers {
    
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

                if json[key][i]["type"].stringValue != "Vrij" {
                    
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
                                        start: course["start"].intValue,
                                        end: course["end"].intValue,
                                        room: course["afspraakObject"]["lokaal"].intValue,
                                        week_no: json["w_no"].intValue,
                                        homework: homework,
                                        test: test)
                    
                    
                    lessonArray.append(lesson)
                    
                } else {
                    
                    // Only append the type, day & hour to spare hours
                    
                    let course = json[key][i]

                    let lesson = Lesson(day: course["day"].stringValue,
                                        type: course["afspraakObject"]["type"].stringValue,
                                        hour: course["afspraakObject"]["lesuur"].intValue,
                                        lessonGroup: nil,
                                        teacher: nil,
                                        teacherSmall: nil,
                                        teacherTitle: nil,
                                        lessonTitle: nil,
                                        homeworkDescription: nil,
                                        start: nil,
                                        end: nil,
                                        room: nil,
                                        week_no: nil,
                                        homework: nil,
                                        test: nil)

                    lessonArray.append(lesson)

                }
                
            }

        }
        
        return lessonArray
    }
    
    func getLessons() {
        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lessons")
        
        //3
        do {
            let results =
                try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

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
                    
                    let lesson = NSManagedObject(entity: e, insertInto: managedContext)
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
