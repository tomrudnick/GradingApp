//
//  Course.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import Foundation
import CoreData

extension Course {
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue}
    }
    
    var subject: String {
        get { subject_ ?? "" }
        set { subject_ = newValue}
    }
    
    var title: String {
        get {subject + " " + name}
    }
    var oralWeight: Float {
        get { Float(weight_) }
        set { weight_ = Int32(newValue)}
    }
    
    var students: Set<Student> {
        get { students_ as? Set<Student> ?? [] }
        set { students_ = newValue as NSSet}
    }
    
    var ageGroup: AgeGroup {
        get { AgeGroup(rawValue: ageGroup_)!}
        set { ageGroup_ = newValue.rawValue }
    }
    
    var type: CourseType {
        get { CourseType(rawValue: type_)!}
        set { type_ = newValue.rawValue }
    }
    
    var studentsArr: Array<Student> {
        get { students.sorted { $0.firstName < $1.firstName }.sorted{ $0.lastName < $1.lastName } }
    }
}


@objc
public enum AgeGroup : Int16 {
    case lower = 0
    case upper = 1
}

@objc
public enum CourseType: Int16 {
    case holeYear = 0
    case firstHalf = 1
    case secondHalf = 2
}


extension Course {
    convenience init(name: String, subject: String, hidden: Bool = false, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.subject = subject
        self.hidden = hidden
    }
    
    
    convenience init(name: String, subject: String, hidden: Bool = false, ageGroup: AgeGroup, type: CourseType, oralWeight: Float, context: NSManagedObjectContext) {
        self.init(name: name, subject: subject, hidden: hidden, context: context)
        self.type = type
        self.ageGroup = ageGroup
        self.oralWeight = oralWeight
    }
    
    
    static func addCourse(courseName: String, courseSubject: String, oralWeight: Float, ageGroup: AgeGroup, type: CourseType, hidden: Bool = false, context: NSManagedObjectContext) {
        _ = Course(name: courseName, subject: courseSubject, hidden: hidden, ageGroup: ageGroup, type: type, oralWeight: oralWeight, context: context)
        context.saveCustom()
    }
    
    static func fetchAll() -> NSFetchRequest<Course> {
        let request = NSFetchRequest<Course>(entityName: "Course")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Course.subject_, ascending: true)]
        return request
    }
    
    static func fetchAllNonHidden() -> NSFetchRequest<Course> {
        let request = fetchAll()
        request.predicate = NSPredicate(format: "hidden == NO")
        return request
    }
}

extension Course {
    
    func getNumberOfGrades(for range: ClosedRange<Int>, half: HalfType) -> Int{
        var counter = 0
        for student in self.students {
            if range.contains(Int(student.totalGradeAverage(half: half))) {
                counter += 1
            }
        }
        return counter
    }
    
    func getChartData(half: HalfType) -> [(String,Int)] {
        var data: [(String,Int)] = []
        data.append(("Sehr gut", getNumberOfGrades(for: 13...15, half: half)))
        data.append(("Gut", getNumberOfGrades(for: 10...12, half: half)))
        data.append(("Befriedigend", getNumberOfGrades(for: 7...9, half: half)))
        data.append(("Ausreichend", getNumberOfGrades(for: 4...6, half: half)))
        data.append(("Mangelhaft", getNumberOfGrades(for: 1...3, half: half)))
        data.append(("Ungenügend", getNumberOfGrades(for: 0...0, half: half)))
        print(data)
        return data
    }
    
    func getChartDataNumbers(half: HalfType) -> [Double] {
        var data: [Double] = []
        data.append(Double(getNumberOfGrades(for: 13...15, half: half)))
        data.append(Double(getNumberOfGrades(for: 10...12, half: half)))
        data.append(Double(getNumberOfGrades(for: 7...9, half: half)))
        data.append(Double(getNumberOfGrades(for: 4...6, half: half)))
        data.append(Double(getNumberOfGrades(for: 1...3, half: half)))
        data.append(Double(getNumberOfGrades(for: 0...0, half: half)))
        return data
    }
    
    func gradeSystem () -> [String] {
        switch self.ageGroup {
        case .upper:
            return Grade.uppperSchoolGrades
        case .lower:
          return Grade.lowerSchoolGrades
        }
    }
}



