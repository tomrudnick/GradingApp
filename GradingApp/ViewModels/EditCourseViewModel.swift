//
//  EditCourseViewModel.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 05.08.21.
//
//Diese Klasse ist eine Kopie unserer Kurse und ist nur für den EditCourseView da.
//Die nexted Classe CourseVM bildet unseres Courses Klasse nach. Es gibt in CourseVM aber
//keine Studenten.
//Mit der fetchCourses Funktion werden vorhandenen Kurse aus der Datenbank geholt und
//von diesen Kursen wird eine Kopie angelegt und in das Array courses geschrieben.
//
//Es wird über alle aus der Datenbank geladenen Funktionen iteriert und mit den Kopien
//verglichen. Ist eine Kopie mit der id vorhanden, wird sie einfach in die Datenbank
//geschrieben. Ist die Kopie nicht vorhanden, wird der Kurs aus der Datenbank gelöscht.

// Die Klasse ist so designt das nur an einem einzigen Punkt gespeichert wird
// und es gibt ebenfalls nur einen Fetch aller Daten die beim Speichern einmalig
// verglichen und gegebenfalls gelöscht / geändert werden.

import Foundation
import CoreData

class CourseEditViewModel: ObservableObject {
    @Published var courses: [CourseVM] = []
    private var fetchedCourses: [UUID : Course] = [:] // SHOULD NEVER BE ACCESSIBLE FROM THE OUTSIDE
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCourses()
    }
    
    private func fetchCourses() {
        let fetchedData = PersistenceController.fetchData(context: context, fetchRequest: Course.fetchAll())
        self.fetchedCourses = Dictionary(uniqueKeysWithValues: fetchedData.map {(UUID(), $0)})
        self.courses = fetchedCourses.map({ (key: UUID, value: Course) in
            CourseVM(id: key, name: value.name, hidden: value.hidden, deleted: false,
                     fetchedStudents: Dictionary(uniqueKeysWithValues: value.students.map {(UUID(), $0)}))
        }).sorted(by: { $0.name < $1.name })
    }
    
    func save() {
        for (id, course) in fetchedCourses {
            if let courseVM = courses.first(where: {$0.id == id}) {  // where: {course: Course in course.id == id}
                if courseVM.deleted {
                    context.delete(course)
                } else {
                    course.name = courseVM.name
                    course.hidden = courseVM.hidden
                    //maybe extract this part into CourseVM Model
                    for (id, student) in courseVM.fetchedStudents {
                        if let studentModel = courseVM.students.first(where: {$0.id == id}) { //this should probably never fail (untested) (maybe replace with guard)
                            if studentModel.deleted {
                                context.delete(student)
                            } else {
                                student.update(for: studentModel)
                            }
                        }
                    }
                }
            } else {
                context.delete(course)
            }
        }
        context.saveCustom()
    }
    
    func deleteCoursesEdit(atOffsets indexSet: IndexSet) {
        let coursesToDelete = indexSet.map { self.courses[$0] }
        for course in coursesToDelete {
            course.deleted = true
        }
    }
    
    class CourseVM : ObservableObject, Identifiable{
        var id: UUID
        @Published var name: String
        @Published var hidden: Bool
        @Published var deleted: Bool
        private(set) var fetchedStudents: [UUID : Student] // SHOULD NEVER BE WRITABLE FROM THE OUTSIDE
        @Published var students: [Student.DataModel]
        init(id: UUID = UUID(), name: String, hidden: Bool, deleted: Bool, fetchedStudents: [UUID : Student]) {
            self.id = id
            self.name = name
            self.hidden = hidden
            self.deleted = deleted
            self.fetchedStudents = fetchedStudents
            self.students = self.fetchedStudents.map { (key: UUID, value: Student) in
                Student.DataModel(id: key, firstName: value.firstName, lastName: value.lastName, email: value.email)
            }.sorted(by: { $0.lastName < $1.lastName })
        }
        
        func deleteStudentCoursesEdit(atOffsets indexSet: IndexSet)  {
            for index in indexSet {
                students[index].toggleDelete()
            }
        }
        
        func updateStudent(for student: Student.DataModel) {
            guard let studentIndex = students.firstIndex(where: {$0.id == student.id}) else {
                fatalError("Something went terribly wrong while trying to delete a student")
            }
            students[studentIndex].update(for: student)
        }
        
        func deleteStudentCoursesEdit(id: UUID)  {
            guard let studentIndex = students.firstIndex(where: {$0.id == id}) else {
                fatalError("Something went terribly wrong while trying to delete a student")
            }
            students[studentIndex].toggleDelete()
        }
    }
}
