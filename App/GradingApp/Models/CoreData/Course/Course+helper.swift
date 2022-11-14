//
//  Course.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import Foundation
import CoreData

extension Course {
    
    public var id: UUID {
        get {
            if let id_ {
                return id_
            } else {
                id_ = UUID()
                return id_!
            }
        }
        
        set {
            id_ = newValue
        }
    }
    
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
        get {
            students.filter { $0.hidden == false }
            .sorted { s1, s2 in
                Student.compareStudents(s1, s2)
            }
        }
    }
    
    var studentsCount: Int {
        get { students.filter { $0.hidden == false}.count }
    }
}


@objc
public enum AgeGroup : Int16, Codable {
    case lower = 0
    case upper = 1
}

@objc
public enum CourseType: Int16, Codable {
    case holeYear = 0
    case firstHalf = 1
    case secondHalf = 2
}


extension Course {
    convenience init(name: String, subject: String, hidden: Bool = false, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
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
    
    convenience init(name: String, subject: String, hidden: Bool = false, ageGroup: AgeGroup, type: CourseType, oralWeight: Float, schoolYear: SchoolYear, context: NSManagedObjectContext) {
        self.init(name: name, subject: subject, hidden: hidden, context: context)
        self.type = type
        self.ageGroup = ageGroup
        self.oralWeight = oralWeight
        self.schoolyear = schoolYear
    }
    
    
    static func addCourse(courseName: String, courseSubject: String, oralWeight: Float, ageGroup: AgeGroup, type: CourseType, hidden: Bool = false, schoolYear: SchoolYear, context: NSManagedObjectContext) {
        _ = Course(name: courseName, subject: courseSubject, hidden: hidden, ageGroup: ageGroup, type: type, oralWeight: oralWeight, schoolYear: schoolYear, context: context)
        context.saveCustom()
    }
    static func addCourse(course: CourseEditViewModel.CourseVM, context: NSManagedObjectContext){
        addCourse(courseName: course.name, courseSubject: course.subject, oralWeight: course.oralWeight, ageGroup: course.ageGroup, type: course.type, hidden: course.hidden, schoolYear: course.schoolYear, context: context)
    }
    
    static func getAddCourse(course: CourseEditViewModel.CourseVM, context: NSManagedObjectContext) -> Course {
        let course = Course(name: course.name, subject: course.subject, hidden: course.hidden, ageGroup: course.ageGroup, type: course.type, oralWeight: course.oralWeight, schoolYear: course.schoolYear, context: context)
        context.saveCustom()
        return course
    }
    
    static func fetchRequest(forID id: UUID) -> NSFetchRequest<Course> {
        let request = fetchAll()
        request.predicate = NSPredicate(format: "id_ = %@", id as CVarArg)
        return request
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
    
    static func fetchHalfNonHidden(half: HalfType) -> NSFetchRequest<Course> {
        let request = fetchAll()
        let courseType = half == .firstHalf ? CourseType.firstHalf : CourseType.secondHalf
        request.predicate = NSPredicate(format: "hidden == NO AND (type_ == %d OR type_ == %d)", courseType.rawValue, CourseType.holeYear.rawValue)
        return request
    }
    
    static func fetchHalfNonHiddenSchoolYear(half: HalfType, schoolYear: SchoolYear) -> NSFetchRequest<Course>{
        let request = fetchAll()
        let courseType = half == .firstHalf ? CourseType.firstHalf : CourseType.secondHalf
        request.predicate = NSPredicate(format: "schoolyear == %@ AND hidden == NO AND (type_ == %d OR type_ == %d)", schoolYear, courseType.rawValue, CourseType.holeYear.rawValue)
        return request
    }
    
    static func fetchSchoolYear(schoolYear: SchoolYear) -> NSFetchRequest<Course> {
        let request = fetchAll()
        request.predicate = NSPredicate(format: "schoolyear == %@", schoolYear)
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
    
    func getSurnameBeginLetters() -> [Character] {
        var surnameLetterSet: Set<Character> = []
        self.students.forEach { if let letter = $0.lastName.lowercased().first { surnameLetterSet.insert(letter) } }
        return surnameLetterSet.sorted()
    }
}



