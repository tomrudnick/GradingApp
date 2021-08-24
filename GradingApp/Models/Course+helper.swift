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
    
    var studentsArr: Array<Student> {
        get { students.sorted { $0.firstName < $1.firstName }.sorted{ $0.lastName < $1.lastName } }
    }
}


@objc
public enum AgeGroup : Int16 {
    case lower = 0
    case upper = 1
}


extension Course {
    convenience init(name: String, hidden: Bool = false, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.hidden = hidden
    }
    
    convenience init(name: String, hidden: Bool = false, ageGroup: AgeGroup, oralWeight: Float, context: NSManagedObjectContext) {
        self.init(name: name, hidden: hidden, context: context)
        self.ageGroup = ageGroup
        self.oralWeight = oralWeight
    }
    
    
    static func addCourse(courseName: String, oralWeight: Float, ageGroup: AgeGroup, hidden: Bool = false, context: NSManagedObjectContext) {
        _ = Course(name: courseName, hidden: hidden, ageGroup: ageGroup, oralWeight: oralWeight, context: context)
        context.saveCustom()
    }
    
    
    static func fetchAll() -> NSFetchRequest<Course> {
        let request = NSFetchRequest<Course>(entityName: "Course")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Course.name_, ascending: true)]
        return request
    }
    
    static func fetchAllNonHidden() -> NSFetchRequest<Course> {
        let request = fetchAll()
        request.predicate = NSPredicate(format: "hidden == NO")
        return request
    }
}

extension Course {
    
    func getNumberOfGrades(for range: ClosedRange<Int>) -> Int{
        var counter = 0
        for student in self.students {
            if range.contains(Int(student.totalGradeAverage())) {
                counter += 1
            }
        }
        return counter
    }
    
    func getChartData() -> [(String,Int)] {
        var data: [(String,Int)] = []
        data.append(("Sehr gut", getNumberOfGrades(for: 13...15)))
        data.append(("Gut", getNumberOfGrades(for: 10...12)))
        data.append(("Befriedigend", getNumberOfGrades(for: 7...9)))
        data.append(("Ausreichend", getNumberOfGrades(for: 4...6)))
        data.append(("Mangelhaft", getNumberOfGrades(for: 1...3)))
        data.append(("Ungenügend", getNumberOfGrades(for: 0...0)))
        print(data)
        return data
    }
    
    func getChartDataNumbers() -> [Double] {
        var data: [Double] = []
        data.append(Double(getNumberOfGrades(for: 13...15)))
        data.append(Double(getNumberOfGrades(for: 10...12)))
        data.append(Double(getNumberOfGrades(for: 7...9)))
        data.append(Double(getNumberOfGrades(for: 4...6)))
        data.append(Double(getNumberOfGrades(for: 1...3)))
        data.append(Double(getNumberOfGrades(for: 0...0)))
        return data
    }
}

