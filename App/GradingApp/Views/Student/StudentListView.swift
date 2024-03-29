//
//  StudentListView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentListView: View {
    
    @ObservedObject var course: Course
    @Environment(\.currentHalfYear) var halfYear

    internal var didAppear: ((Self) -> Void)?
    
    var body: some View {
        List {
            ForEach(course.studentsArr) { student in
                NavigationLink(value: Route.student(student)) {
                    HStack {
                        Text(student.firstName).frame(alignment: .leading)
                        Text(student.lastName).frame(alignment: .leading)
                    }
                }
            }
        }.onAppear {
            self.didAppear?(self)
        }
    }
}


//----------------------------Preview-------------------------------
//struct StudentListView_Previews: PreviewProvider {
//
//    static let course = previewData(context: PersistenceController.preview.container.viewContext).first!
//
//    static var previews: some View {
//
//            StudentListView(course: course)
//
//    }
//}
