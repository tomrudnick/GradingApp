//
//  EditCourseViewModel.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 05.08.21.
//

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
            CourseVM(id: key, name: value.name, hidden: value.hidden)
        }).sorted(by: { $0.name < $1.name })
    }
    
    func save() {
        for (id, course) in fetchedCourses {
            if let courseVM = courses.first(where: {$0.id == id}) {
                course.name = courseVM.name
                course.hidden = courseVM.hidden
            } else {
                container.viewContext.delete(course)
            }
        }
        PersistenceController.saveData()
    }
    
    func deleteCoursesEdit(atOffsets indexSet: IndexSet) {
        courses.remove(atOffsets: indexSet)
    }
    
    class CourseVM : ObservableObject, Identifiable{
        var id: UUID
        @Published var name: String
        @Published var hidden: Bool
        
        init(id: UUID = UUID(), name: String, hidden: Bool) {
            self.id = id
            self.name = name
            self.hidden = hidden
        }
    }
    
}
