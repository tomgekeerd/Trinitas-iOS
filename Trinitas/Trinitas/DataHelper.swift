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
import SecureNSUserDefaults

enum LessonType {
    
    case Vrij
    case EersteUurVrij
    case Tussenuur
    case Les
    case Pauze
    
}

struct Lesson {
    
    // Required
    
    var day: String!
    var type: LessonType!
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

struct Mail {
    
    var preview_text: String!
    var message_url: String!
    var sender_first: String!
    var sender_last: String!
    var sender_profile_url: String!
    var attachments: Bool!
    var date: Date!
    var forwarded: Bool!
    var read: Bool!
    var replied: Bool!
    var sender_id: Int!
    var message_id: Int!

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
    
    func user() -> User? {
        
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
                            
                            if let type = result.type {
                                
                                let t = self.helpers.getLessonType(withType: type)
                                
                                let lesson = Lesson(day: result.day,
                                                    type: t,
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
    
    func needsUpdate(date: Date, forced: Bool) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let dateStamp = dateFormatter.string(from: date)
        
        var needsUpdate = false
        
        // Check for saturdays & sundays...
        
        let comp = date.components
        if comp.weekday != 1 && comp.weekday != 7 {
            
            // Get AppDelegate
            
            if !forced {
                
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
                                
                                if Int(Date().timeIntervalSince1970) - Int(r.lastUpdate) > 60 * 5 {
                                    needsUpdate = true
                                }
                                
                            }
                            
                        } else {
                            
                            needsUpdate = true
                            
                        }
                    }
                    
                }
                
            } else {
                
                needsUpdate = true
                
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
                        f.setValue(self.helpers.getType(withLesson: les.type), forKey: "type")
                        
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
                        lesson.setValue(self.helpers.getType(withLesson: les.type), forKey: "type")

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
    
    // MARK: - Itslearning CoreData
    
    func saveMail(withData mail: JSON) {
        
        // Get AppDelegate
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate ?? nil
        if let app = appDelegate {
            
            // Retrieve context & entity

            let managedContext = app.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Mails", in: managedContext)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            if let e = entity {
                
                // Check if mail already exists...
                
                if let message_id = mail["MessageId"].int {
                    
                    fetchRequest.entity = e
                    let mIdPredicate = NSPredicate(format: "message_id = %i", message_id)
                    fetchRequest.predicate = mIdPredicate
                    
                    var fetchResults = [Mails]()
                    do {
                        if let results = try managedContext.fetch(fetchRequest) as? [Mails] {
                            fetchResults = results
                        }
                    } catch {
                        fatalError("Something went wrong fetching...")
                    }
                    
                    // Had to this weird solution because NSManagedObject does not want to initiate without inserting...
                    
                    if fetchResults.count == 0 {
                        
                        // Insert new one
                        
                        let newMail = Mails(entity: e, insertInto: managedContext)
                        
                        if let message_id = mail["MessageId"].int,
                            let date = mail["DateReceived"].string,
                            let forwarded = mail["IsForwarded"].bool,
                            let attachments = mail["HasAttachments"].bool,
                            let message_url = mail["MessageUrl"].string,
                            let preview_text = mail["PreviewText"].string,
                            let read = mail["IsRead"].bool,
                            let replied = mail["IsReplied"].bool,
                            let sender_first = mail["From"]["FirstName"].string,
                            let sender_id = mail["From"]["PersonId"].int,
                            let sender_last = mail["From"]["LastName"].string,
                            let sender_profile_url = mail["From"]["ProfileUrl"].string,
                            let text = mail["Text"].string,
                            let subject = mail["Subject"].string {
                            
                            // Set values :p
                            
                            newMail.setValue(attachments, forKey: "attachments")
                            newMail.setValue(date, forKey: "date")
                            newMail.setValue(forwarded, forKey: "forwarded")
                            newMail.setValue(message_id, forKey: "message_id")
                            newMail.setValue(message_url, forKey: "message_url")
                            newMail.setValue(preview_text, forKey: "preview_text")
                            newMail.setValue(read, forKey: "read")
                            newMail.setValue(replied, forKey: "replied")
                            newMail.setValue(sender_first, forKey: "sender_first")
                            newMail.setValue(sender_id, forKey: "sender_id")
                            newMail.setValue(sender_last, forKey: "sender_last")
                            newMail.setValue(sender_profile_url, forKey: "sender_profile_url")
                            newMail.setValue(text, forKey: "text")
                            newMail.setValue(subject, forKey: "subject")
                            
                        }
                        
                    }
                    
                }
                
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
                                    type: self.getLessonType(withType: course["afspraakObject"]["type"].stringValue),
                                    date: date,
                                    hour: course["afspraakObject"]["lesuur"].intValue,
                                    lastUpdate: Int(Date().timeIntervalSince1970),
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
        
    func getType(withLesson lessonType: LessonType) -> String {
        
        switch lessonType {
        case .Vrij:
            return "Vrij"
        case .EersteUurVrij:
            return "Eerste uur vrij"
        case .Tussenuur:
            return "Tussenuur"
        case .Les:
            return "Les"
        case .Pauze:
            return "Pauze"
        }
        
    }
    
    func getLessonType(withType type: String) -> LessonType {
        
        switch type {
            case "Vrij":
                return .Vrij
            case "Eerste uur vrij":
                return .EersteUurVrij
            case "Tussenuur":
                return .Tussenuur
            case "Les":
                return .Les
            case "Pauze":
                return .Pauze
        default: ()
        }
        
        return .Vrij
        
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
    
    
    // MARK: - Itslearning
    
    func saveRefreshToken(withToken token: String) {
        UserDefaults.standard.setSecretObject(token, forKey: "refresh_token")
        print(UserDefaults.standard.secretObject(forKey: "refresh_token"))
    }
    
    func retrieveRefreshToken() -> String? {
        if let refreshToken = UserDefaults.standard.secretObject(forKey: "refresh_token") as? String {
            return refreshToken
        } else {
            return nil
        }
    }
    
}

extension Date {
    var components: DateComponents {
        let cal = NSCalendar.current
        return cal.dateComponents(Set([.year, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear, .yearForWeekOfYear]), from: self)
    }
}
