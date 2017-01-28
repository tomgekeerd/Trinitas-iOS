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

// Lesson

enum LessonType {
    case Vrij
    case EersteUurVrij
    case Tussenuur
    case Les
    case Pauze
}

struct Lesson {
    var day: String!
    var type: LessonType!
    var date: String!
    
    var hour: Int!
    var lastUpdate: Int!
    
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

// Mail

struct Mail {
    var preview_text: String
    var message_url: String
    var attachments: Bool
    var date: String
    var forwarded: Bool
    var read: Bool
    var replied: Bool
    var message_id: Int
    var text: String?
    var subject: String?
    var from: ItslearningPerson
    var to: [ItslearningPerson]?
}

struct ItslearningPerson {
    var profile_url: String
    var person_id: Int
    var first_name: String
    var last_name: String
}

// Grades

struct Grade {
    var period: Int
    var mark: String
    var description: String
    var count: String
    var section: String
}

struct GradePeriod {
    var period: Int
    var sections: [Section]
}

struct Section {
    var name: String
    var grades: [Grade]
    var average: String
}

// Personal

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
    
    // MARK: - Itslearning
    
    func getPersons(withJsonData jsonData: [JSON]) -> [ItslearningPerson] {
        
        var personData = [ItslearningPerson]()
        for person in jsonData {
            
            if let profile_url = person["ProfileUrl"].string,
                let person_id = person["PersonId"].int,
                let first_name = person["FirstName"].string,
                let last_name = person["LastName"].string {
                
                let person = ItslearningPerson(profile_url: profile_url,
                                               person_id: person_id,
                                               first_name: first_name,
                                               last_name: last_name)
                
                personData.append(person)
                
            }

        }
        
        return personData
        
    }
    
    func getMails(withJsonData jsonData: [JSON]) -> [Mail] {
        
        var mailData = [Mail]()
        for mail in jsonData {
            
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
                let subject = mail["Subject"].string {
            
                // Set values :p
                
                let from = ItslearningPerson(profile_url: sender_profile_url,
                                             person_id: sender_id,
                                             first_name: sender_first,
                                             last_name: sender_last)
                
                let mail = Mail(preview_text: preview_text,
                                message_url: message_url,
                                attachments: attachments,
                                date: date,
                                forwarded: forwarded,
                                read: read,
                                replied: replied,
                                message_id: message_id,
                                text: nil,
                                subject: subject,
                                from: from,
                                to: nil)
                
                mailData.append(mail)

            }
            
        }
        
        return mailData
        
    }
    
    // MARK: - Grades
    
    func getGradesData(withJsonData json: JSON) -> [GradePeriod] {
        
        var gradePeriods = [GradePeriod]()
        if let periodArray = json.dictionary {
            
            for (periodId, sections) in periodArray {
                
                if let sectionsDict = sections.dictionary {
                    
                    var sectionArray = [Section]()
                    for (sectionId, grades) in sectionsDict {
                        
                        var gradeArray = [Grade]()
                        if let grades = grades.array {
                            
                            for grade in grades {
                                
                                let g = Grade(period: Int(periodId)!,
                                              mark: grade["mark"].stringValue,
                                              description: grade["description"].stringValue,
                                              count: grade["count"].stringValue,
                                              section: grade["section"].stringValue)
                                gradeArray.append(g)
                                
                            }
                            
                        }
                        
                        var total = 0.0
                        for grade in gradeArray {
                            total = total + Double(grade.mark)! * Double(grade.count)!
                        }
                        let avg = total / Double(gradeArray.count).roundTo(places: 1)

                        let section = Section(name: sectionId,
                                              grades: gradeArray,
                                              average: String(avg))
                        sectionArray.append(section)
                    }
                    
                    sectionArray = sectionArray.sorted(by: { $0.name < $1.name })                    
                    let period = GradePeriod(period: Int(periodId)!,
                                             sections: sectionArray)
                    gradePeriods.append(period)
                    
                }
                
            }
            
        }
        
        return gradePeriods

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

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIViewController {
    func present(alertWithTitle title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
}
