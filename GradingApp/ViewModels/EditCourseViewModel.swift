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

import Foundation

class CourseEditViewModel: ObservableObject {
    @Published var courses: [CourseVM] = []
    private var fetchedCourses: [UUID : Course] = [:]
    private var container = PersistenceController.shared.container
    
    init() {
       fetchCourses()
    }
    
    private func fetchCourses() {
        let fetchedData = PersistenceController.fetchData(fetchRequest: Course.fetchAll())
        self.fetchedCourses = Dictionary(uniqueKeysWithValues: fetchedData.map {(UUID(), $0)})
        self.courses = fetchedCourses.map({ (key: UUID, value: Course) in
            CourseVM(id: key, name: value.name, hidden: value.hidden, deleted: false)
        }).sorted(by: { $0.name < $1.name })
    }
    
    func save() {
        for (id, course) in fetchedCourses {
            if let courseVM = courses.first(where: {$0.id == id}) {  // where: {course: Course in course.id == id}
                if courseVM.deleted {
                    container.viewContext.delete(course)
                } else {
                    course.name = courseVM.name
                    course.hidden = courseVM.hidden
                }
            } else {
                container.viewContext.delete(course)
            }
        }
        PersistenceController.saveData()
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
        init(id: UUID = UUID(), name: String, hidden: Bool, deleted: Bool) {
            self.id = id
            self.name = name
            self.hidden = hidden
            self.deleted = deleted
        }
    }
//  Code for Previews
    
    
}
