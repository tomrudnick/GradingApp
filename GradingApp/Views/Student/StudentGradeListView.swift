//
//  StudentGradeListView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.08.21.
//

import SwiftUI
import SwiftUICharts

struct StudentGradeListView: View {
    @ObservedObject var course: Course
    @State private var action: Student? = nil
    @State var data2: [Double] = (0..<16).map { _ in .random(in: 9.0...100.0) }
    let mixedColorStyle = ChartStyle(backgroundColor: .white, foregroundColor: [
            ColorGradient(Color(red: 0.173, green: 0.894, blue: 0.455), Color(red: 0.173, green: 0.894, blue: 0.455)),
            ColorGradient(Color(red: 0.803, green: 0.941, blue: 0.229), Color(red: 0.803, green: 0.941, blue: 0.229)),
            ColorGradient(Color(red: 1.0, green: 0.898, blue: 0.0), Color(red: 1.0, green: 0.898, blue: 0.0)),
            ColorGradient(Color(red: 1.0, green: 0.592, blue: 0.0), Color(red: 1.0, green: 0.592, blue: 0.0)),
            ColorGradient(Color(red: 1.0, green: 0.224, blue: 0.141), Color(red: 1.0, green: 0.224, blue: 0.141)),
            ColorGradient(Color(red: 0.737, green: 0.067, blue: 0.0), Color(red: 0.737, green: 0.067, blue: 0.0))
        ])
    var body: some View {
        
        ScrollView {
            VStack {
                CardView {
                    ChartLabel("Notenverteilung", type: .legend)
                    BarChart()
                }
                .data(course.getChartDataNumbers())
                .chartStyle(mixedColorStyle)
                .frame(height: 240)
                .padding()
                ForEach(course.studentsArr) { student in
                    VStack {
                        NavigationLink(destination: StudentView(student: student), tag: student, selection: $action) {
                            EmptyView()
                        }
                        HStack {
                            StudentDetailListView(student: student)
                            Button {
                                action = student
                            } label: {
                                Image(systemName: "exclamationmark.circle").font(.system(size: 20))
                            }.padding(.leading)
                        }.padding()
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1.5)
                            .edgesIgnoringSafeArea(.horizontal)
                    }
                    
                }
            }
        }
    }
}


struct StudentDetailListView: View {
    @ObservedObject var student: Student
    
    var body: some View {
        VStack {
            HStack {
                Text(student.firstName)
                Spacer()
                Text("\(student.getRoundedGradeAverage()) (\(student.getGradeAverage()))")
                    .foregroundColor(Grade.getColor(points: student.totalGradeAverage()))
            }
            HStack {
                Text(student.lastName).bold()
                VStack(spacing: 0) {
                    Divider()
                }
            }.padding(.top, -8)
            HStack {
                Text("Mündlich: ")
                Text("\(student.getRoundedGradeAverage(.oral)) (\(student.getGradeAverage(.oral)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .oral)))
                Spacer()
            }
            HStack {
                Text("Schriftlich: ")
                Text("\(student.getRoundedGradeAverage(.written)) (\(student.getGradeAverage(.written)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .written)))
                Spacer()
            }
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

/*struct CourseListGradeView_Previews: PreviewProvider {
    static var previews: some View {
        StudentGradeListView()
    }
}*/
